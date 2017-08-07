/*global app, File, ElementPlacement, CMYKColor, ColorModel, SpotColor,
         BlendModes, PDFSaveOptions*/

// 1in = 25.4mm = 72pt
function mm2pt(value) {
  return value * 72 / 25.4;
}

function Builder() {
  this.doc = app.documents.add();

  // 傳入值以 mm 為單位, 但 AI 以 pt 為單位
  this.setPageSize = function (width, height) {
    this.width = mm2pt(width);
    this.height = mm2pt(height);
    this.doc.artboards[0].artboardRect = [0, this.height, this.width, 0];
  };

  this.setPrintImage = function (path) {
    var layer = this.getLayer('Artwork');
    var placedItem = layer.placedItems.add();
    placedItem.file = new File(path); // 一定要給完整的絕對路徑, 不然會噴找不到檔案
    // 位置指定必須在嵌入前, 因為嵌入會將 placedItem 轉成別的東西,
    // 而這裡沒有任何 API 能取得那個東西 (即使你知道那是一個 RasterItem)
    // 這兩個值的意義代表 "物件的左上角" 與 "原點" 之間的距離
    placedItem.left = 0;
    placedItem.top = this.height;
    placedItem.embed(); // 指定要嵌入進檔案, 不然 AI 只會保存檔案的參考而非完整檔案
  };

  this.createCoatingBackground = function () {
    var layer = this.getLayer('Coating');
    var spotColor = this.getSpotColor('Coating', 0, 0, 0, 10);
    var path = layer.pathItems.rectangle(this.height, 0, this.width, this.height);
    this.setItemColor(path, spotColor);
    return path;
  };

  this.addCoating = function (path, scaleX, scaleY, positionX, positionY, orientation) {
    var layer = this.getLayer('Coating');
    var spotColor = this.getSpotColor('Coating', 0, 0, 0, 10);
    this.createSVGItem(layer, path, scaleX, scaleY, positionX, positionY, orientation, spotColor);
  };

  this.mergeCoatingLayer = function () {
    var i;
    var layer = this.getLayer('Coating');
    var items = this.itemsToArray(layer.groupItems);
    var groupItem = layer.groupItems.add();
    for (i = 0; i < items.length; i++) {
      items[i].move(groupItem, ElementPlacement.PLACEATEND);
    }
    this.doc.selection = groupItem;
    app.executeMenuCommand('Live Pathfinder Add');
    app.executeMenuCommand('expandStyle');
  };

  this.inverseCoatingLayer = function () {
    var layer = this.getLayer('Coating');
    if (layer.groupItems.length === 0) {
      return;
    }
    var background = layer.groupItems[0];
    this.createCoatingBackground().move(background, ElementPlacement.PLACEATEND);
    this.doc.selection = background;
    app.executeMenuCommand('Live Pathfinder Subtract');
    app.executeMenuCommand('expandStyle');
  };

  this.createFoilingBackground = function () {
    var layer = this.getLayer('Foiling');
    var spotColor = this.getSpotColor('Foiling', 0, 0, 50, 0);
    var path = layer.pathItems.rectangle(this.height, 0, this.width, this.height);
    this.setItemColor(path, spotColor);
    return path;
  };

  this.addFoiling = function (path, scaleX, scaleY, positionX, positionY, orientation) {
    var layer = this.getLayer('Foiling');
    var spotColor = this.getSpotColor('Foiling', 0, 0, 50, 0);
    this.createSVGItem(layer, path, scaleX, scaleY, positionX, positionY, orientation, spotColor);
  };

  this.mergeFoilingLayer = function () {
    var i;
    var layer = this.getLayer('Foiling');
    var items = this.itemsToArray(layer.groupItems);
    var groupItem = layer.groupItems.add();
    for (i = 0; i < items.length; i++) {
      items[i].move(groupItem, ElementPlacement.PLACEATEND);
    }
    this.doc.selection = groupItem;
    app.executeMenuCommand('Live Pathfinder Add');
    app.executeMenuCommand('expandStyle');
  };

  this.inverseFoilingLayer = function () {
    var layer = this.getLayer('Foiling');
    if (layer.groupItems.length === 0) {
      return;
    }
    var background = layer.groupItems[0];
    this.createFoilingBackground().move(background, ElementPlacement.PLACEATEND);
    this.doc.selection = background;
    app.executeMenuCommand('Live Pathfinder Subtract');
    app.executeMenuCommand('expandStyle');
  };

  this.createSVGItem = function (layer, path, scaleX, scaleY, positionX, positionY, orientation, spotColor) {
    var groupItem = layer.groupItems.createFromFile(new File(path));
    groupItem.left = this.transformPositionX(groupItem, positionX);
    groupItem.top = this.transformPositionY(groupItem, positionY);
    groupItem.resize(scaleX, scaleY);
    groupItem.rotate(orientation);
    this.setSpotColorRecursive(groupItem, spotColor);
    return groupItem;
  };

  this.transformPositionX = function (groupItem, x) {
    return x + (this.width / 2) - (groupItem.width / 2);
  };

  this.transformPositionY = function (groupItem, y) {
    return (this.height / 2) + (groupItem.height / 2) - y;
  };

  this.getLayer = function (name) {
    try {
      return this.doc.layers.getByName(name); // 沒有的話會噴錯
    } catch (e) {
      var layer = this.doc.layers.add();
      layer.name = name;
      return layer;
    }
  };

  this.getSpotColor = function (name, cyan, magenta, yellow, black) {
    var spot;
    try {
      spot = this.doc.spots.getByName(name); // 沒有的話會噴錯
    } catch (e) {
      var color = new CMYKColor();
      color.cyan = cyan;
      color.magenta = magenta;
      color.yellow = yellow;
      color.black = black;

      spot = this.doc.spots.add();
      spot.color = color;
      spot.colorType = ColorModel.SPOT;
      spot.name = name;
    }
    var spotColor = new SpotColor();
    spotColor.spot = spot;
    return spotColor;
  };

  this.setSpotColorRecursive = function (item, color) {
    var i, compoundPath;

    if (item.pathItems !== undefined) {
      for (i = 0; i < item.pathItems.length; i++) {
        this.setItemColor(item.pathItems[i], color);
      }
    }

    if (item.compoundPathItems !== undefined) {
      for (i = 0; i < item.compoundPathItems.length; i++) {
        compoundPath = item.compoundPathItems[i];
        this.setSpotColorRecursive(compoundPath, color);
      }
    }

    if (item.groupItems !== undefined) {
      for (i = 0; i < item.groupItems.length; i++) {
        this.setSpotColorRecursive(item.groupItems[i], color);
      }
    }
  };

  this.setItemColor = function (item, color) {
    item.strokeColor = color;
    item.fillColor = color;
    item.blendingMode = BlendModes.DARKEN; // 透明度設定為暗化
  };

  this.itemsToArray = function (items) {
    var i, array = [];
    for (i = 0; i < items.length; i++) {
      array.push(items[i]);
    }
    return array;
  };

  this.cleanup = function () {
    this.mergeCoatingLayer();
    // this.inverseCoatingLayer(); // 上光不需要反轉
    this.mergeFoilingLayer();
    this.inverseFoilingLayer();
    this.removeLastLayer();
  };

  this.removeLastLayer = function () {
    this.doc.layers[this.doc.layers.length - 1].remove();
  };

  this.exportAI = function (path) {
    this.doc.saveAs(new File(path));
  };

  this.exportPDF = function (path) {
    this.doc.saveAs(new File(path), new PDFSaveOptions());
  };

  this.close = function () {
    this.doc.close();
  };

  return this;
}

function main(args) {
  var i;
  var builder = new Builder();
  args = JSON.parse(args[1]);

  builder.setPageSize(args.pageSize.width, args.pageSize.height);
  builder.setPrintImage(args.item.image);

  for (i = 0; i < args.item.layers.length; i++) {
    var layer = args.item.layers[i];
    switch (layer.type) {
      case 'coating':
      builder.addCoating(layer.image,
                         layer.scaleX,
                         layer.scaleY,
                         layer.positionX,
                         layer.positionY,
                         layer.angle);
      break;
      case 'foiling':
      builder.addFoiling(layer.image,
                         layer.scaleX,
                         layer.scaleY,
                         layer.positionX,
                         layer.positionY,
                         layer.angle);
      break;
    }
  }

  builder.cleanup();

  if (args.exportAI) {
    builder.exportAI(args.exportAI);
  }

  if (args.exportPDF) {
    builder.exportPDF(args.exportPDF);
  }

  builder.close();
}

function Builder() {
  // 開啟 template 檔案, 該檔案規格如下:
  // 1. Artboard 的左下角必須對齊 (0, 0) 的位置
  // 2. 必須有 "Template" layer
  // 3. Template layer 中, 使用路徑定義貼紙的形狀與位置, 並且要命名為 "Sticker"
  // 4. Template layer 中, 使用路徑定義切割線的形狀與位置, 並且要命名為 "Kisscut"
  // 5. Template layer 中, 使用文字定義想填入文字的位置, 並且適當命名 (拼版後臺要填入的名稱)
  // 6. Template layer 中, 其他不需要特別處理, 但希望印出來的靜態元件, 命名為 "Fixed"
  this.setTemplate = function (template) {
    this.doc = app.open(new File(template));
    this.width = this.doc.width;
    this.height = this.doc.height;
    this.models = [];
    this.qrcodes = [];
    this.currentModelIndex = -1;

    var layer = this.getLayer('Template')
    var subItemPointers = {}

    var i, pathItems = this.getLayer('Template').pathItems;
    for (i = 0; i < pathItems.length; i++) {
      pathItem = pathItems[i]
      if (pathItem.name == 'Sticker') {
        this.models.push(new Model(this, pathItem));
      } else if (pathItem.name == 'QRCode') {
        pointer = subItemPointers[pathItem.name] || 0;
        model = this.models[pointer];
        model.qrcodeItem = pathItem;
        subItemPointers[pathItem.name] = pointer + 1;
      }
    }

    var textFrames = this.getLayer('Template').textFrames;

    for (i = 0; i < textFrames.length; i++) {
      textFrame = textFrames[i];
      if (textFrame.name == 'ProductName' || textFrame.name == 'OrderNumber') {
        pointer = subItemPointers[textFrame.name] || 0;
        model = this.models[pointer];
        model.textFrames.push(textFrame);
        subItemPointers[textFrame.name] = pointer + 1;
      }
    }
  };

  this.addItem = function (item) {

    var i;
    var model = this.nextModel();

    if (!item.image) {
      return model.buildEmptyGroup();
    }

    var image = new File(item.image);
    model.drawImage(image);

    // var qrcodeLayer = this.qrcodes[this.currentModelIndex];
    var qrcodeLayer = model.qrcodeItem

    if(qrcodeLayer){
      this.setQRCode(item.qrcode, qrcodeLayer);
    }

    // 2016.3.23 先不處理光燙金、雷射雕刻...之類的
    // for (i = 0; i < item.layers.length; i++) {
    //   var layer = item.layers[i];
    //   switch (layer.type) {
    //     case 'coating':
    //     model.addCoating(layer.image, layer.scaleX, layer.scaleY, layer.positionX, layer.positionY, layer.angle);
    //     break;
    //     case 'foiling':
    //     model.addFoiling(layer.image, layer.scaleX, layer.scaleY, layer.positionX, layer.positionY, layer.angle);
    //     break;
    //   }
    // }

    for (i = 0; i < item.labels.length; i++) {
      var label = item.labels[i]
      this.setLabel(model, label.name, label.content);
    }
  };

  this.nextModel = function () {
    this.currentModelIndex++;
    return this.models[this.currentModelIndex];
  };

  this.setQRCode = function(qrcode, qrcodeTemplate) {
    var layer = this.getLayer('QRCode');
    var qrcodeItem = this.importSVG(layer, qrcode);

    qrcodeItem.left = qrcodeTemplate.left;
    qrcodeItem.top = qrcodeTemplate.top;
    qrcodeItem.width = qrcodeTemplate.width;
    qrcodeItem.height = qrcodeTemplate.height;
  };

  this.setLabel = function (model, labelName, contents) {
    var targetFrame
    for (var i in model.textFrames){
      f = model.textFrames[i]
      if(f.name == labelName){ targetFrame = f; }
    }

    if (targetFrame) {
      var layer = this.getLayer('Labels');
      targetFrame.move(layer, ElementPlacement.PLACEATEND);
      targetFrame.contents = contents;
    }
  };

  // [Start] Copied codes from vanaheim_builder.js
  this.createCutContourLayer = function () {
    var i, pathItems = this.getLayer('Template').pathItems;
    for (i = 0; i < pathItems.length; i++) {
      var match = pathItems[i].name.match(/CutContour([1-8])/);
      if (match) {
        var pathItem = pathItems[i].duplicate();
        var layer = this.getLayer(pathItem.name);
        pathItem.move(layer, ElementPlacement.PLACEATEND);
        pathItem.strokeDashes = [];
        this.setItemStrokeColor(pathItem, this.getCutContourColor(match[1]));
      }
    }
  };

  this.setItemStrokeColor = function (item, color) {
    item.strokeColor = color;
    item.fillColor = new NoColor();
    item.blendingMode = BlendModes.DARKEN; // 透明度設定為暗化
  };

  this.getCutContourColor = function(n) {
    return this.getSpotColor('CutContour' + n, 0, 100, 100, 0);
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
  // [End] Copied

  this.cleanup = function () {
    this.eachModel(function(model) {
      model.createClippingMask();
    });
    this.mergeStickersLayer();
    // 2016.3.23 先不處理光燙金、雷射雕刻...之類的
    // this.mergeCoatingLayer();
    // this.mergeFoilingLayer();
    this.mergeCMYKLayer();
  };

  this.mergeStickersLayer = function() {
    var i, layer = this.getLayer('Stickers');
    var groupItems = this.itemsToArray(layer.groupItems);

    for (i = 0; i < groupItems.length; i++) {
      var groupItem = groupItems[i];
      var items = [];
      while (groupItem.pageItems.length > 0) {
        items.push(groupItem.pageItems[0]);
        groupItem.pageItems[0].move(groupItem.parent, ElementPlacement.PLACEATEND);
      }

      this.doc.selection = items;
      app.executeMenuCommand('makeMask');
    }
  };

  this.mergeCoatingLayer = function () {
    var i;
    var layer = this.getLayer('Coating');
    var items = this.itemsToArray(layer.groupItems);
    var parentGroupItem = layer.groupItems.add();

    var coatingGroupItem = parentGroupItem.groupItems.add();
    for (i = 0; i < items.length; i++) {
      items[i].move(coatingGroupItem, ElementPlacement.PLACEATEND);
    }

    var coatingBackground = this.createCoatingBackground();
    coatingBackground.move(coatingGroupItem, ElementPlacement.PLACEATEND);

    this.doc.selection = parentGroupItem;
    app.executeMenuCommand('Live Pathfinder Subtract');
    app.executeMenuCommand('expandStyle');

    // 反相上光區域
    coatingBackground = this.createCoatingBackground();
    coatingBackground.move(layer.groupItems[0], ElementPlacement.PLACEATEND);
    this.doc.selection = layer.groupItems[0];
    app.executeMenuCommand('Live Pathfinder Subtract');
    app.executeMenuCommand('expandStyle');
  };

  this.mergeFoilingLayer = function () {
    var i;
    var layer = this.getLayer('Foiling');
    var items = this.itemsToArray(layer.groupItems);
    var parentGroupItem = layer.groupItems.add();

    var foilingGroupItem = parentGroupItem.groupItems.add();
    for (i = 0; i < items.length; i++) {
      items[i].move(foilingGroupItem, ElementPlacement.PLACEATEND);
    }

    var foilingBackground = this.createFoilingBackground();
    foilingBackground.move(foilingGroupItem, ElementPlacement.PLACEATEND);

    this.doc.selection = parentGroupItem;
    app.executeMenuCommand('Live Pathfinder Subtract');
    app.executeMenuCommand('expandStyle');
  };

  this.mergeCMYKLayer = function () {
    var i, j, pageItem;
    var cmykLayer = this.getLayer('CMYK');
    var templateLayer = this.getLayer('Template');
    var layers = ['Labels', 'QRCode', 'Stickers'];

    var pageItems = templateLayer.pageItems;
    for (i = 0; i < pageItems.length; i++) {
      if (pageItems[i].name == 'Fixed') {
        pageItem = pageItems[i].duplicate();
        pageItem.move(cmykLayer, ElementPlacement.PLACEATEND);
      }
    }
    templateLayer.remove();

    for (i = 0; i < layers.length; i++) {
      var layer = this.getLayer(layers[i]);
      for (j = 0; j < layer.pageItems.length; j++) {
        pageItem = layer.pageItems[j].duplicate();
        pageItem.move(cmykLayer, ElementPlacement.PLACEATEND);
      }

      layer.remove();
    }
  };

  // Helpers

  this.getLayer = function (name) {
    try {
      return this.doc.layers.getByName(name); // 沒有的話會噴錯
    } catch (e) {
      var layer = this.doc.layers.add();
      layer.name = name;
      return layer;
    }
  };

  this.eachModel = function (callback) {
    var i;
    for (i = 0; i < this.models.length; i++) {
      callback(this.models[i]);
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

  this.getCoatingColor = function() {
    return this.getSpotColor('Coating', 0, 0, 0, 10);
  };

  this.getFoilingColor = function() {
    return this.getSpotColor('Foiling', 0, 0, 50, 0);
  };

  this.getKisscutColor = function() {
    return this.getSpotColor('Kisscut', 0, 100, 100, 0);
  };

  this.itemsToArray = function (items) {
    var i, array = [];
    for (i = 0; i < items.length; i++) {
      array.push(items[i]);
    }
    return array;
  };

  this.createCoatingBackground = function () {
    var layer = this.getLayer('Coating');
    var spotColor = this.getCoatingColor();
    var path = layer.pathItems.rectangle(0, 0, this.width, -this.height);
    this.setItemColor(path, spotColor);
    return path;
  };

  this.createFoilingBackground = function () {
    var layer = this.getLayer('Foiling');
    var spotColor = this.getFoilingColor();
    var path = layer.pathItems.rectangle(0, 0, this.width, -this.height);
    this.setItemColor(path, spotColor);
    return path;
  };

  this.setItemColor = function (item, color) {
    item.strokeColor = color;
    item.fillColor = color;
    item.blendingMode = BlendModes.DARKEN; // 透明度設定為暗化
  };

  this.importSVG = function (layer, path) {
    var groupItem = layer.groupItems.createFromFile(new File(path));
    return groupItem;
  };

  this.export = function (path) {
    this.doc.saveAs(new File(path), new PDFSaveOptions());
  };

  this.close = function () {
    this.doc.close();
  };
}

function Model(builder, pathItem) {
  this.builder = builder;
  this.pathItem = pathItem;
  this.coatingItems = [];
  this.foilingItems = [];
  this.textFrames = [];
  this.qrcodeItem = null;

  this.buildEmptyGroup = function() {
    var layer = this.builder.getLayer('Stickers');
    var groupItem = layer.groupItems.add();
    this.imageGroupItem = groupItem;

    var pathItem = this.pathItem.duplicate();
    pathItem.move(groupItem, ElementPlacement.PLACEATEND);

    var placedItem = layer.placedItems.add();

    placedItem.move(groupItem, ElementPlacement.PLACEATEND);
  };

  this.drawImage = function (image) {
    // 建立 groupItem 並將 path 與 image 放入
    var layer = this.builder.getLayer('Stickers');
    // 這個 GroupItem 將會包含 [貼紙路徑, 圖片]
    var groupItem = layer.groupItems.add();
    // 將貼紙路徑放入 GroupItem 變成 [貼紙路徑]
    var pathItem = this.pathItem.duplicate();
    pathItem.move(groupItem, ElementPlacement.PLACEATEND);
    // 將圖片匯入並放入 GroupItem 變成 [貼紙路徑, 圖片]
    var placedItem = layer.placedItems.add();
    placedItem.file = image;
    // 位置指定必須在嵌入前, 因為嵌入會將 placedItem 轉成別的東西,
    // 而這裡沒有任何 API 能取得那個東西 (即使你知道那是一個 RasterItem)
    // 這兩個值的意義代表 "物件的左上角" 與 "原點" 之間的距離
    var pathItemRatio = pathItem.width / pathItem.height;
    var placedItemRatio = placedItem.width / placedItem.height;
    var originPlacedItemWidth = placedItem.width;
    // 計算該有的大小與位置, 貼至符合貼紙大小的範圍內
    if (pathItemRatio > placedItemRatio) {
      placedItem.left = pathItem.left;
      placedItem.top = pathItem.top + Math.abs((pathItem.height - pathItem.width / placedItemRatio) / 2);
      placedItem.width = pathItem.width;
      placedItem.height = pathItem.width / placedItemRatio;
    } else {
      placedItem.left = pathItem.left - Math.abs((pathItem.width - pathItem.height * placedItemRatio) / 2);
      placedItem.top = pathItem.top;
      placedItem.width = pathItem.height * placedItemRatio;
      placedItem.height = pathItem.height;
    }
    this.placeItemScale = placedItem.width / originPlacedItemWidth;

    placedItem.move(groupItem, ElementPlacement.PLACEATEND);
    placedItem.embed();
    // 記住 GroupItem [貼紙路徑, 圖片]
    this.imageGroupItem = groupItem;
  };

  this.addCoating = function (path, scaleX, scaleY, positionX, positionY, orientation) {
    var layer = this.builder.getLayer('Coating');
    var spotColor = this.builder.getCoatingColor();
    var groupItem = this.createSVGItem(layer, path, scaleX, scaleY, positionX, positionY, orientation, spotColor);
    this.coatingItems.push(groupItem);
  };

  this.addFoiling = function (path, scaleX, scaleY, positionX, positionY, orientation) {
    var layer = this.builder.getLayer('Foiling');
    var spotColor = this.builder.getFoilingColor();
    var groupItem = this.createSVGItem(layer, path, scaleX, scaleY, positionX, positionY, orientation, spotColor);
    this.foilingItems.push(groupItem);
  };

  this.createClippingMask = function () {
    // 將 [貼紙路徑, 圖片] 變成 [貼紙路徑, 圖片, []]
    var groupItem = this.imageGroupItem.groupItems.add();

    if(this.imageGroupItem.pathItems.length > 0){

      // 將 [貼紙路徑, 圖片, []] 變成 [圖片, [貼紙路徑]]
      this.imageGroupItem.pathItems[0].move(groupItem, ElementPlacement.PLACEATEND);

      // 將 [圖片, [貼紙路徑]] 變成 [圖片, [貼紙路徑, 燙金路徑...]]
      var i, items = [];
      for (i = 0; i < this.foilingItems.length; i++) {
        var item = this.foilingItems[i].duplicate();
        item.move(groupItem, ElementPlacement.PLACEATEND);
      }
    }
    // Duang!
    this.builder.doc.selection = groupItem;
    app.executeMenuCommand('Live Pathfinder Minus Back');
    app.executeMenuCommand('expandStyle');
    app.executeMenuCommand('compoundPath');
  };

  // Helpers

  this.createSVGItem = function (layer, path, scaleX, scaleY, positionX, positionY, orientation, spotColor) {
    var groupItem = layer.groupItems.createFromFile(new File(path));
    groupItem.left = this.transformPositionX(groupItem, positionX);
    groupItem.top = this.transformPositionY(groupItem, positionY);
    groupItem.resize(scaleX * this.placeItemScale, scaleY * this.placeItemScale);
    groupItem.rotate(orientation);
    this.setSpotColorRecursive(groupItem, spotColor);
    return groupItem;
  };

  // 這邊的算式有點複雜, 兩者的座標系是完全不一樣的:
  // * Layer 採用的是向下/向右為正, 中心點在中央
  // * Illustrator 採用的是向上/向右為正, 中心點在左下方
  this.transformPositionX = function (groupItem, x) {
    return x * this.placeItemScale - (groupItem.width / 2) + (this.pathItem.width / 2) + this.pathItem.left;
  };

  this.transformPositionY = function (groupItem, y) {
    return (groupItem.height / 2) - y * this.placeItemScale - (this.pathItem.height / 2) + this.pathItem.top;
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
}

function main(args) {
  var i;
  var builder = new Builder();
  args = JSON.parse(args[1]);
  builder.setTemplate(args.template);

  for (i = 0; i < builder.models.length; i++) {
    var item = args.items[i] || {};
    builder.addItem(item);
  }

  builder.createCutContourLayer();
  builder.cleanup();
  builder.export(args.output);
  builder.close();
}

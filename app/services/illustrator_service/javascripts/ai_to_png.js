function main(args) {
  var doc = app.open(new File(args[1]));

  var pngOptions = new ExportOptionsPNG24();
  pngOptions.artBoardClipping = true;
  pngOptions.transparency = false;

  doc.exportFile(new File(args[2]), ExportType.PNG24, pngOptions);
  doc.close(SaveOptions.DONOTSAVECHANGES);
}

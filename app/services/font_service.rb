class FontService
  include Singleton

  # 看 Google 文件 "字體清單"
  AVAILABLE_FONTS = [
    {name: 'Abel',                 file: 'Abel-Regular.ttf'},
    {name: 'Akbar',                file: 'akbar.ttf'},
    {name: 'Amatic',               file: 'Amatic-Bold.ttf'},
    {name: 'Bangers',              file: 'Bangers.ttf'},
    {name: 'Billy',                file: 'billy.ttf'},
    {name: 'Bite Bullet',          file: 'Bite___Bullet.ttf'},
    {name: 'Changa One',           file: 'ChangaOne-Italic.ttf'},
    {name: 'Cinzel',               file: 'Cinzel-Regular.otf'},
    {name: 'Close',                file: 'Close.otf'},
    {name: 'Fabu',                 file: 'Fabu-Regular.ttf'},
    {name: 'Fredoka One',          file: 'FredokaOne-Regular.ttf'},
    {name: 'Lobster1.4',           file: 'Lobster_1.4.otf'},
    {name: 'Megrim',               file: 'Megrim.ttf'},
    {name: 'Raleway Dots',         file: 'RalewayDots-Regular.ttf'},
    {name: 'Snickles',             file: 'Snickles.ttf'},
    {name: 'SUNN',                 file: 'SUNN.otf'},
    {name: 'Uglyhandwriting',      file: 'uglyhandwriting.ttf'},
    {name: 'Wire One',             file: 'WireOne.ttf'}
  ]

  def fonts
    @fonts ||= AVAILABLE_FONTS.map { |data| Font.new(data) }
  end

  class Font
    include ActiveModel::Model

    attr_accessor :name, :file

    def class_name
      "font-#{name.parameterize}"
    end

    def path
      "fonts/#{file}"
    end
  end
end

shared_context 'take screenshot', js: true do
  def oss
    page.driver.render('tmp/ss.png', full: true)
    `open tmp/ss.png`
  end
end

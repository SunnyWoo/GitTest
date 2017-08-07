shared_context 'come from Taiwan', come_from: 'Taiwan' do
  before do
    # 來自台灣
    page.driver.add_header('REMOTE_ADDR', '202.39.253.11', permanent: true)
    page.driver.add_header('X-Forwarded-For', '202.39.253.11', permanent: true)
    page.driver.add_header('Accept-Language', 'zh-TW', permanent: true)
  end
end

shared_context 'come from China', come_from: 'China' do
  before do
    # 來自中國
    page.driver.add_header('REMOTE_ADDR', '180.76.3.151', permanent: true)
    page.driver.add_header('X-Forwarded-For', '180.76.3.151', permanent: true)
    page.driver.add_header('Accept-Language', 'zh-CN', permanent: true)
  end
end

shared_context 'come from Japan', come_from: 'Japan' do
  before do
    # 來自日本
    page.driver.add_header('REMOTE_ADDR', '203.209.152.96', permanent: true)
    page.driver.add_header('X-Forwarded-For', '203.209.152.96', permanent: true)
    page.driver.add_header('Accept-Language', 'ja', permanent: true)
  end
end

shared_context 'come from Hong Kong', come_from: 'Hong Kong' do
  before do
    # 來自香港
    page.driver.add_header('REMOTE_ADDR', '202.155.223.120', permanent: true)
    page.driver.add_header('X-Forwarded-For', '202.155.223.120', permanent: true)
    page.driver.add_header('Accept-Language', 'zh-HK', permanent: true)
  end
end

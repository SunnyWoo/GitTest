=begin
@apiDefine ApiV3
@apiHeader {String="application/vnd.commandp.v3+json"} Accept
=end
class Api::V3::AnnouncementsController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {get} /api/announcements Get announcement list
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Announcements
@apiName GetAnnouncements
@apiSuccessExample {json} Success-Response:
  {
    "announcements": [
       {
         'id': 1,
         'message': 'Foo Bar'
       }
     ]
  }
=end
  def index
    @announcements = Announcement.lists
  end
end

class AnnouncementCell < Cell::Rails
  def announcement
    @announcements = Announcement.lists
    render
  end
end

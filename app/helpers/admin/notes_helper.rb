module Admin::NotesHelper
  def admin_noteable_notes_path(noteable)
    polymorphic_path([:admin, noteable, :notes], locale: I18n.locale)
  end

  def new_admin_noteable_note_path(noteable)
    new_polymorphic_path([:admin, noteable, Note.new])
  end

  def render_order_item_note(order_item)
    order_item.notes.last.try(:message) || 'Notes'
  end
end

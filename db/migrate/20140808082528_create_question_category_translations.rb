class CreateQuestionCategoryTranslations < ActiveRecord::Migration
  def up
    QuestionCategory.create_translation_table!({
      name: :string
    }, {
      migrate_data: true
    })
  end

  def down
    QuestionCategory.drop_translation_table! migrate_data: true
  end
end

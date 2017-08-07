class CreateQuestionTranslations < ActiveRecord::Migration
  def up
    Question.create_translation_table!({
      question: :string,
      answer: :text
    }, {
      migrate_data: true
    })
  end

  def down
    Question.drop_translation_table! migrate_data: true
  end
end

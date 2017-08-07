class String

  def language
    LanguageDetector.what_lang(self)
  end

end

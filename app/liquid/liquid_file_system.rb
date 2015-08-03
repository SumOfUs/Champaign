class LiquidFileSystem
  def read_template_file(title)
    LiquidPartial.where(title: title).first.content
  end
end

class TargetsCSVFormatter
  def self.run(targets)
    headers = []
    content = ''
    targets.each do |target|
      target.keys.each do |key|
        headers << key unless headers.include?(key)
      end

      content += headers.map { |key| target.get(key) }.join(',')
      content += "\n"
    end

    headers = headers.join(',')
    "#{headers}\n#{content}"
  end
end

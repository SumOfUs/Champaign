class CSVFormatter
  def self.run(rows)
    headers = []
    content = ''
    rows.each do |row|
      row.keys.each do |key|
        headers << key unless headers.include?(key)
      end

      content += CSV::Row.new(headers, headers.map { |key| row[key] }).to_s
    end

    headers = headers.join(',')
    "#{headers}\n#{content}"
  end
end

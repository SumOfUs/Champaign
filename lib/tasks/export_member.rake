namespace :export_member_data do
  desc 'Export members data as csv files'
  task :csv, %i[email path] => :environment do |_t, args|
    raise 'usage:  rake export_member_data:csv[<email>[,<path>]]' if args[:email].blank?

    member = Member.find_by_email(args[:email])
    csv_map = MemberExporter.to_csv(member)
    full_path = File.join(
      Rails.root,
      args[:path] || '',
      "member_#{member.id}"
    )
    FileUtils.mkdir_p full_path

    csv_map.each do |category, csv|
      File.open(File.join(full_path, "#{category}.csv"), 'w') do |file|
        file.write(csv)
      end
    end
    puts "CSV files written to #{full_path}"
  end
end

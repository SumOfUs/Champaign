class RemovePostalCodeFromTargets < ActiveRecord::Migration
  class Call < ActiveRecord::Base; end
  class Plugins::CallTool < ActiveRecord::Base; end

  def up
    batch_size = 300
    Call.find_in_batches(batch_size: batch_size) do |group|
      group.each do |call|
        target = call.read_attribute(:target)
        target.delete('postal_code')
        call.update!(target: target)
      end
    end

    Plugins::CallTool.find_in_batches(batch_size: batch_size) do |group|
      group.each do |call_tool|
        targets = call_tool.read_attribute(:targets)
        targets.each { |t| t.delete('postal_code') }
        call_tool.update!(targets: targets)
      end
    end
  end
end

MagicLamp.configure do |config|

  Dir[Rails.root.join("spec", "support/factories.rb")].each { |f| load f }
  Dir[Rails.root.join("spec", "javascripts", "support", "magic_lamp_helpers/**/*.rb")].each { |f| load f }

  LiquidMarkupSeeder.seed

  # if you want to require the name parameter for the `fixture` method
  config.infer_names = false

  config.global_defaults = { extend: AuthStub }

  config.before_each do
    puts "I appear before the block passed to `fixture` executes!"
  end

  config.after_each do
    puts "I appear after like a ghost from beyond the pale the block passed to `fixture` executes!"
  end
end

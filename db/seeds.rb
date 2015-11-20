puts "Seeding..."


# Languages
languages =  [
    {code: 'en', name: 'English'},
    {code: 'fr', name: 'French'},
    {code: 'de', name: 'German'}
]

Language.create!(languages)

# Forms

basic_form = Form.create name: "Basic", master: true

basic_form_fields = [
  {label: 'Email Address', name: 'email',  required: true,  data_type: 'email', form: basic_form},
  {label: 'Full Name',     name: 'name',   required: true,  data_type: 'text', form: basic_form},
  {label: 'Postal Code',   name: 'postal', required: true,  data_type: 'text', form: basic_form}
]

FormElement.create!(basic_form_fields)

# Create tags and their associations to ActionKit
Tag.create!([
  {name: '*Welcome_Sequence', actionkit_uri: '/rest/v1/tag/1000/'},
  {name: '#Animal_Rights', actionkit_uri: '/rest/v1/tag/944/'},
  {name: '!French', actionkit_uri: '/rest/v1/tag/1130/'},
  {name: '!German', actionkit_uri: '/rest/v1/tag/1132/'},
  {name: '#Net_Neutrality', actionkit_uri: '/rest/v1/tag/1078/'},
  {name: '*FYI_and_VIP', actionkit_uri: '/rest/v1/tag/980/'},
  {name: '@Germany', actionkit_uri: '/rest/v1/tag/1036/'},
  {name: '!English', actionkit_uri: '/rest/v1/tag/1282/'},
  {name: '@NewZealand', actionkit_uri: '/rest/v1/tag/1140/'},
  {name: '@France', actionkit_uri: '/rest/v1/tag/1128/'},
  {name: '#Sexism', actionkit_uri: '/rest/v1/tag/1208/'},
  {name: '#Disability_Rights', actionkit_uri: '/rest/v1/tag/1040/'},
  {name: '@Austria', actionkit_uri: '/rest/v1/tag/1042/'},
  {name: '@Switzerland', actionkit_uri: '/rest/v1/tag/1043/'},
  {name: '#Anti_Racism', actionkit_uri: '/rest/v1/tag/945/'},
  {name: '#Consumer_Protection', actionkit_uri: '/rest/v1/tag/946/'},
  {name: '#Economic_Justice', actionkit_uri: '/rest/v1/tag/941/'},
  {name: '#Environment', actionkit_uri: '/rest/v1/tag/942/'},
  {name: '#Food_and_GMOs', actionkit_uri: '/rest/v1/tag/940/'},
  {name: '#Human_Rights_and_Civil_Liberties', actionkit_uri: '/rest/v1/tag/574/'},
  {name: '#LGBT_Rights', actionkit_uri: '/rest/v1/tag/938/'},
  {name: '#Media_Accountability', actionkit_uri: '/rest/v1/tag/937/'},
  {name: '#Privatization_and_Political_Meddling', actionkit_uri: '/rest/v1/tag/947/'},
  {name: '#Shareholder_Activism', actionkit_uri: '/rest/v1/tag/943/'},
  {name: '#Womens_Rights', actionkit_uri: '/rest/v1/tag/934/'},
  {name: '#Workers_Rights', actionkit_uri: '/rest/v1/tag/933/'},
  {name: '*Petition', actionkit_uri: '/rest/v1/tag/971/'},
  {name: '*Call-in', actionkit_uri: '/rest/v1/tag/973/'},
  {name: '*Event', actionkit_uri: '/rest/v1/tag/976/'},
  {name: '*Fundraiser', actionkit_uri: '/rest/v1/tag/972/'},
  {name: '*Letters_or_Comments', actionkit_uri: '/rest/v1/tag/975/'},
  {name: '*Other_High_Bar_Action', actionkit_uri: '/rest/v1/tag/977/'},
  {name: '*Social_Media', actionkit_uri: '/rest/v1/tag/974/'},
  {name: '+MVP', actionkit_uri: '/rest/v1/tag/948/'},
  {name: '+Test', actionkit_uri: '/rest/v1/tag/949/'},
  {name: '+Full_Universe', actionkit_uri: '/rest/v1/tag/951/'},
  {name: '+Special_Universe', actionkit_uri: '/rest/v1/tag/964/'},
  {name: '+Kicker', actionkit_uri: '/rest/v1/tag/952/'},
  {name: '@Australia', actionkit_uri: '/rest/v1/tag/969/'},
  {name: '@Canada', actionkit_uri: '/rest/v1/tag/967/'},
  {name: '@Europe', actionkit_uri: '/rest/v1/tag/954/'},
  {name: '@Global', actionkit_uri: '/rest/v1/tag/953/'},
  {name: '@Multi_Country', actionkit_uri: '/rest/v1/tag/956/'},
  {name: '@NorthAmerica', actionkit_uri: '/rest/v1/tag/955/'},
  {name: '@Other_National', actionkit_uri: '/rest/v1/tag/970/'},
  {name: '@UK', actionkit_uri: '/rest/v1/tag/968/'},
  {name: '@USA', actionkit_uri: '/rest/v1/tag/966/'}
])

# Liquid Markup
LiquidMarkupSeeder.seed

User.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

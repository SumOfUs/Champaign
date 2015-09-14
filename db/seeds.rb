# Languages
languages =  [
    {code: 'en', name: 'English'},
    {code: 'fr', name: 'French'},
    {code: 'de', name: 'German'}
]

Language.create!(languages)

# Liquid Markup
LiquidMarkupSeeder.seed


# Forms

basic_form = Form.create name: "Basic", master: true

basic_form_fields = [
  {label: 'Email Address', required: true,  data_type: 'email', form: basic_form},
  {label: 'Full Name',     required: true,  data_type: 'text', form: basic_form},
  {label: 'Postal Code',   required: true,  data_type: 'text', form: basic_form}
]

FormElement.create!(basic_form_fields)

# Create tags and their associations to ActionKit
Tag.create!([
  {tag_name: '*Welcome_Sequence', actionkit_uri: '/rest/v1/tag/1000/'},
  {tag_name: '#Animal_Rights', actionkit_uri: '/rest/v1/tag/944/'},
  {tag_name: '!French', actionkit_uri: '/rest/v1/tag/1130/'},
  {tag_name: '!German', actionkit_uri: '/rest/v1/tag/1132/'},
  {tag_name: '#Net_Neutrality', actionkit_uri: '/rest/v1/tag/1078/'},
  {tag_name: '*FYI_and_VIP', actionkit_uri: '/rest/v1/tag/980/'},
  {tag_name: '@Germany', actionkit_uri: '/rest/v1/tag/1036/'},
  {tag_name: '!English', actionkit_uri: '/rest/v1/tag/1282/'},
  {tag_name: '@NewZealand', actionkit_uri: '/rest/v1/tag/1140/'},
  {tag_name: '@France', actionkit_uri: '/rest/v1/tag/1128/'},
  {tag_name: '#Sexism', actionkit_uri: '/rest/v1/tag/1208/'},
  {tag_name: '#Disability_Rights', actionkit_uri: '/rest/v1/tag/1040/'},
  {tag_name: '@Austria', actionkit_uri: '/rest/v1/tag/1042/'},
  {tag_name: '@Switzerland', actionkit_uri: '/rest/v1/tag/1043/'},
  {tag_name: '#Anti_Racism', actionkit_uri: '/rest/v1/tag/945/'},
  {tag_name: '#Consumer_Protection', actionkit_uri: '/rest/v1/tag/946/'},
  {tag_name: '#Economic_Justice', actionkit_uri: '/rest/v1/tag/941/'},
  {tag_name: '#Environment', actionkit_uri: '/rest/v1/tag/942/'},
  {tag_name: '#Food_and_GMOs', actionkit_uri: '/rest/v1/tag/940/'},
  {tag_name: '#Human_Rights_and_Civil_Liberties', actionkit_uri: '/rest/v1/tag/574/'},
  {tag_name: '#LGBT_Rights', actionkit_uri: '/rest/v1/tag/938/'},
  {tag_name: '#Media_Accountability', actionkit_uri: '/rest/v1/tag/937/'},
  {tag_name: '#Privatization_and_Political_Meddling', actionkit_uri: '/rest/v1/tag/947/'},
  {tag_name: '#Shareholder_Activism', actionkit_uri: '/rest/v1/tag/943/'},
  {tag_name: '#Womens_Rights', actionkit_uri: '/rest/v1/tag/934/'},
  {tag_name: '#Workers_Rights', actionkit_uri: '/rest/v1/tag/933/'},
  {tag_name: '*Petition', actionkit_uri: '/rest/v1/tag/971/'},
  {tag_name: '*Call-in', actionkit_uri: '/rest/v1/tag/973/'},
  {tag_name: '*Event', actionkit_uri: '/rest/v1/tag/976/'},
  {tag_name: '*Fundraiser', actionkit_uri: '/rest/v1/tag/972/'},
  {tag_name: '*Letters_or_Comments', actionkit_uri: '/rest/v1/tag/975/'},
  {tag_name: '*Other_High_Bar_Action', actionkit_uri: '/rest/v1/tag/977/'},
  {tag_name: '*Social_Media', actionkit_uri: '/rest/v1/tag/974/'},
  {tag_name: '+MVP', actionkit_uri: '/rest/v1/tag/948/'},
  {tag_name: '+Test', actionkit_uri: '/rest/v1/tag/949/'},
  {tag_name: '+Full_Universe', actionkit_uri: '/rest/v1/tag/951/'},
  {tag_name: '+Special_Universe', actionkit_uri: '/rest/v1/tag/964/'},
  {tag_name: '+Kicker', actionkit_uri: '/rest/v1/tag/952/'},
  {tag_name: '@Australia', actionkit_uri: '/rest/v1/tag/969/'},
  {tag_name: '@Canada', actionkit_uri: '/rest/v1/tag/967/'},
  {tag_name: '@Europe', actionkit_uri: '/rest/v1/tag/954/'},
  {tag_name: '@Global', actionkit_uri: '/rest/v1/tag/953/'},
  {tag_name: '@Multi_Country', actionkit_uri: '/rest/v1/tag/956/'},
  {tag_name: '@NorthAmerica', actionkit_uri: '/rest/v1/tag/955/'},
  {tag_name: '@Other_National', actionkit_uri: '/rest/v1/tag/970/'},
  {tag_name: '@UK', actionkit_uri: '/rest/v1/tag/968/'},
  {tag_name: '@USA', actionkit_uri: '/rest/v1/tag/966/'}
])


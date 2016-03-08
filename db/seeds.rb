puts "Seeding..."


# Languages
languages = [
    {code: 'en', name: 'English', actionkit_uri: '/rest/v1/language/100/'},
    {code: 'fr', name: 'French',  actionkit_uri: '/rest/v1/language/103/'},
    {code: 'de', name: 'German',  actionkit_uri: '/rest/v1/language/101/'},
    {code: 'es', name: 'Spanish', actionkit_uri: '/rest/v1/language/102/'}
]

languages.each do |language|
  Language.create!(language)
end


# Forms
DefaultFormBuilder.create

# Create tags and their associations to ActionKit
all_tags = [
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
    {name: '@Australia', actionkit_uri: '/rest/v1/tag/969/'},
    {name: '@Canada', actionkit_uri: '/rest/v1/tag/967/'},
    {name: '@Continental_Europe', actionkit_uri: '/rest/v1/tag/954/'},
    {name: '@Rest_Of_World', actionkit_uri: '/rest/v1/tag/1668'},
    {name: '@Global', actionkit_uri: '/rest/v1/tag/953/'},
    {name: '@Other_National', actionkit_uri: '/rest/v1/tag/970/'},
    {name: '@UK', actionkit_uri: '/rest/v1/tag/968/'},
    {name: '@USA', actionkit_uri: '/rest/v1/tag/966/'},
    {name: 'JonL', actionkit_uri: '/rest/v1/tag/1015/'},
    {name: 'KatherineT', actionkit_uri: '/rest/v1/tag/818/'},
    {name: 'LedysS', actionkit_uri: '/rest/v1/tag/992/'},
    {name: 'NicoleC', actionkit_uri: '/rest/v1/tag/1197/'},
    {name: 'EmmaP', actionkit_uri: '/rest/v1/tag/1044/'},
    {name: 'LizM', actionkit_uri: '/rest/v1/tag/1004/'},
    {name: 'PaulF', actionkit_uri: '/rest/v1/tag/821/'},
    {name: 'AngusW', actionkit_uri: '/rest/v1/tag/816/'},
    {name: 'MartinC', actionkit_uri: '/rest/v1/tag/878/'},
    {name: 'AnneI', actionkit_uri: '/rest/v1/tag/1018/'},
    {name: 'WiebkeS', actionkit_uri: '/rest/v1/tag/1200/'},
    {name: 'FatahS', actionkit_uri: '/rest/v1/tag/1102/'},
    {name: 'NabilB', actionkit_uri: '/rest/v1/tag/1465/'},
    {name: 'SondhyaG', actionkit_uri: '/rest/v1/tag/1651/'},
    {name: 'HannaT', actionkit_uri: '/rest/v1/tag/817/'},
    {name: 'RosaK', actionkit_uri: '/rest/v1/tag/1422/'},
    {name: 'EoinD', actionkit_uri: '/rest/v1/tag/1112/'},
    {name: 'HannahL', actionkit_uri: '/rest/v1/tag/982/'},
    {name: 'StevenB', actionkit_uri: '/rest/v1/tag/911/'},
    {name: 'MarkTP', actionkit_uri: '/rest/v1/tag/1019/'},
    {name: 'BexS', actionkit_uri: '/rest/v1/tag/1388/'},
    {name: 'MichaelS', actionkit_uri: '/rest/v1/tag/1160/'},
    {name: 'DeborahL', actionkit_uri: '/rest/v1/tag/1661/'},
    {name: 'KatieF', actionkit_uri: '/rest/v1/tag/1662/'}
]
all_tags.each do |tag|
  Tag.create!(tag)
end


# Liquid Markup
LiquidMarkupSeeder.seed

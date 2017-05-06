# encoding: UTF-8
# coding: UTF-8

require 'csv'
require 'levenshtein'

abbrevcsv = <<-CSVFILE
Afghanistan,AF,AFG,004
Aland Islands,AX,ALA,248
Albania,AL,ALB,008
Algeria,DZ,DZA,012
American Samoa,AS,ASM,016
Andorra,AD,AND,020
Angola,AO,AGO,024
Anguilla,AI,AIA,660
Antarctica,AQ,ATA,010
Antigua and Barbuda,AG,ATG,028
Argentina,AR,ARG,032
Armenia,AM,ARM,051
Aruba,AW,ABW,533
Australia,AU,AUS,036
Austria,AT,AUT,040
Azerbaijan,AZ,AZE,031
Bahamas,BS,BHS,044
Bahrain,BH,BHR,048
Bangladesh,BD,BGD,050
Barbados,BB,BRB,052
Belarus,BY,BLR,112
Belgium,BE,BEL,056
Belize,BZ,BLZ,084
Benin,BJ,BEN,204
Bermuda,BM,BMU,060
Bhutan,BT,BTN,064
Bolivia,BO,BOL,068
Bosnia and Herzegovina,BA,BIH,070
Botswana,BW,BWA,072
Bouvet Island,BV,BVT,074
Brazil,BR,BRA,076
British Virgin Islands,VG,VGB,092
British Indian Ocean Territory,IO,IOT,086
Brunei Darussalam,BN,BRN,096
Bulgaria,BG,BGR,100
Burkina Faso,BF,BFA,854
Burundi,BI,BDI,108
Cambodia,KH,KHM,116
Cameroon,CM,CMR,120
Canada,CA,CAN,124
Cape Verde,CV,CPV,132
Cayman Islands,KY,CYM,136
Central African Republic,CF,CAF,140
Chad,TD,TCD,148
Chile,CL,CHL,152
China,CN,CHN,156
Hong Kong,HK,HKG,344
Macao,MO,MAC,446
Christmas Island,CX,CXR,162
Cocos (Keeling) Islands,CC,CCK,166
Colombia,CO,COL,170
Comoros,KM,COM,174
Congo (Brazzaville),CG,COG,178
"Congo, Democratic Republic of the",CD,COD,180
Cook Islands,CK,COK,184
Costa Rica,CR,CRI,188
Côte d'Ivoire,CI,CIV,384
Croatia,HR,HRV,191
Cuba,CU,CUB,192
Cyprus,CY,CYP,196
Czech Republic,CZ,CZE,203
Denmark,DK,DNK,208
Djibouti,DJ,DJI,262
Dominica,DM,DMA,212
Dominican Republic,DO,DOM,214
Ecuador,EC,ECU,218
Egypt,EG,EGY,818
El Salvador,SV,SLV,222
Equatorial Guinea,GQ,GNQ,226
Eritrea,ER,ERI,232
Estonia,EE,EST,233
Ethiopia,ET,ETH,231
Falkland Islands (Malvinas),FK,FLK,238
Faroe Islands,FO,FRO,234
Fiji,FJ,FJI,242
Finland,FI,FIN,246
France,FR,FRA,250
French Guiana,GF,GUF,254
French Polynesia,PF,PYF,258
French Southern Territories,TF,ATF,260
Gabon,GA,GAB,266
Gambia,GM,GMB,270
Georgia,GE,GEO,268
Germany,DE,DEU,276
Ghana,GH,GHA,288
Gibraltar,GI,GIB,292
Greece,GR,GRC,300
Greenland,GL,GRL,304
Grenada,GD,GRD,308
Guadeloupe,GP,GLP,312
Guam,GU,GUM,316
Guatemala,GT,GTM,320
Guernsey,GG,GGY,831
Guinea,GN,GIN,324
Guinea-Bissau,GW,GNB,624
Guyana,GY,GUY,328
Haiti,HT,HTI,332
Heard Island and Mcdonald Islands,HM,HMD,334
Vatican,VA,VAT,336
Honduras,HN,HND,340
Hungary,HU,HUN,348
Iceland,IS,ISL,352
India,IN,IND,356
Indonesia,ID,IDN,360
Iran,IR,IRN,364
Iraq,IQ,IRQ,368
Ireland,IE,IRL,372
Isle of Man,IM,IMN,833
Israel,IL,ISR,376
Italy,IT,ITA,380
Jamaica,JM,JAM,388
Japan,JP,JPN,392
Jersey,JE,JEY,832
Jordan,JO,JOR,400
Kazakhstan,KZ,KAZ,398
Kenya,KE,KEN,404
Kiribati,KI,KIR,296
"North Korea",KP,PRK,408
"South Korea",KR,KOR,410
Kuwait,KW,KWT,414
Kyrgyzstan,KG,KGZ,417
Lao PDR,LA,LAO,418
Latvia,LV,LVA,428
Lebanon,LB,LBN,422
Lesotho,LS,LSO,426
Liberia,LR,LBR,430
Libya,LY,LBY,434
Liechtenstein,LI,LIE,438
Lithuania,LT,LTU,440
Luxembourg,LU,LUX,442
Macedonia,MK,MKD,807
Madagascar,MG,MDG,450
Malawi,MW,MWI,454
Malaysia,MY,MYS,458
Maldives,MV,MDV,462
Mali,ML,MLI,466
Malta,MT,MLT,470
Marshall Islands,MH,MHL,584
Martinique,MQ,MTQ,474
Mauritania,MR,MRT,478
Mauritius,MU,MUS,480
Mayotte,YT,MYT,175
Mexico,MX,MEX,484
Micronesia,FM,FSM,583
Moldova,MD,MDA,498
Monaco,MC,MCO,492
Mongolia,MN,MNG,496
Montenegro,ME,MNE,499
Montserrat,MS,MSR,500
Morocco,MA,MAR,504
Mozambique,MZ,MOZ,508
Myanmar,MM,MMR,104
Namibia,NA,NAM,516
Nauru,NR,NRU,520
Nepal,NP,NPL,524
Netherlands,NL,NLD,528
Netherlands Antilles,AN,ANT,530
New Caledonia,NC,NCL,540
New Zealand,NZ,NZL,554
Nicaragua,NI,NIC,558
Niger,NE,NER,562
Nigeria,NG,NGA,566
Niue,NU,NIU,570
Norfolk Island,NF,NFK,574
Northern Mariana Islands,MP,MNP,580
Norway,NO,NOR,578
Oman,OM,OMN,512
Pakistan,PK,PAK,586
Palau,PW,PLW,585
Palestine,PS,PSE,275
Panama,PA,PAN,591
Papua New Guinea,PG,PNG,598
Paraguay,PY,PRY,600
Peru,PE,PER,604
Philippines,PH,PHL,608
Pitcairn,PN,PCN,612
Poland,PL,POL,616
Portugal,PT,PRT,620
Puerto Rico,PR,PRI,630
Qatar,QA,QAT,634
Réunion,RE,REU,638
Romania,RO,ROU,642
Russian Federation,RU,RUS,643
Rwanda,RW,RWA,646
Saint-Barthélemy,BL,BLM,652
Saint Helena,SH,SHN,654
Saint Kitts and Nevis,KN,KNA,659
Saint Lucia,LC,LCA,662
Saint-Martin,MF,MAF,663
Saint Pierre and Miquelon,PM,SPM,666
Saint Vincent and Grenadines,VC,VCT,670
Samoa,WS,WSM,882
San Marino,SM,SMR,674
Sao Tome and Principe,ST,STP,678
Saudi Arabia,SA,SAU,682
Senegal,SN,SEN,686
Serbia,RS,SRB,688
Seychelles,SC,SYC,690
Sierra Leone,SL,SLE,694
Singapore,SG,SGP,702
Slovakia,SK,SVK,703
Slovenia,SI,SVN,705
Solomon Islands,SB,SLB,090
Somalia,SO,SOM,706
South Africa,ZA,ZAF,710
South Georgia and the South Sandwich Islands,GS,SGS,239
South Sudan,SS,SSD,728
Spain,ES,ESP,724
Sri Lanka,LK,LKA,144
Sudan,SD,SDN,736
Suriname,SR,SUR,740
Svalbard and Jan Mayen Islands,SJ,SJM,744
Swaziland,SZ,SWZ,748
Sweden,SE,SWE,752
Switzerland,CH,CHE,756
Syria,SY,SYR,760
"Taiwan",TW,TWN,158
Tajikistan,TJ,TJK,762
"Tanzania",TZ,TZA,834
Thailand,TH,THA,764
Timor-Leste,TL,TLS,626
Togo,TG,TGO,768
Tokelau,TK,TKL,772
Tonga,TO,TON,776
Trinidad and Tobago,TT,TTO,780
Tunisia,TN,TUN,788
Turkey,TR,TUR,792
Turkmenistan,TM,TKM,795
Turks and Caicos Islands,TC,TCA,796
Tuvalu,TV,TUV,798
Uganda,UG,UGA,800
Ukraine,UA,UKR,804
United Arab Emirates,AE,ARE,784
United Kingdom,GB,GBR,826
United States of America,US,USA,840
United States Minor Outlying Islands,UM,UMI,581
Uruguay,UY,URY,858
Uzbekistan,UZ,UZB,860
Vanuatu,VU,VUT,548
Venezuela,VE,VEN,862
Viet Nam,VN,VNM,704
"Virgin Islands",VI,VIR,850
Wallis and Futuna Islands,WF,WLF,876
Western Sahara,EH,ESH,732
Yemen,YE,YEM,887
Zambia,ZM,ZMB,894
Zimbabwe,ZW,ZWE,716
CSVFILE

country_lookup = {}
CSV.parse(abbrevcsv) do |row|
  country = I18n.transliterate(row[0])
  country_lookup[row[1]] = country
  country_lookup[row[2]] = country
end
COUNTRY_LOOKUP = country_lookup.freeze
ABBREV_LOOKUP = {
  'ST' => 'Street',
  'AVE' => 'Avenue',
  'AV' => 'Avenue',
  'AVN' => 'Avenue',
  'BLVD' => 'Boulevard',
  'BYP' => 'Bypass',
  'HWY' => 'Highway',
  'CR' => 'Crescent',
  'CRE' => 'Crescent',
  'CRES' => 'Crescent',
  'EST' => 'Estate',
  'EXT' => 'Extension',
  'EXTN' => 'Extension',
  'DRV' => 'Drive',
  'DR' => 'Drive',
  'STE' => 'Suite',
  'RTE' => 'Route',
  'RD' => 'Road',
  'E' => 'East',
  'W' => 'West',
  'N' => 'North',
  'S' => 'South',
  'NE' => 'Northeast',
  'NW' => 'Northwest',
  'SE' => 'Southeast',
  'SW' => 'Southwest',
  'FIRST' => '1st',
  'SECOND' => '2nd',
  'THIRD' => '3rd',
  'FOURTH' => '4th',
  'FIFTH' => '5th',
  'SIXTH' => '6th',
  'TRL' => 'Trail'
}.freeze

class Address
  ADDRESS_COMPONENTS = [:street, :city, :state, :country, :postal_code].freeze

  def initialize(address_components)
    @address_components = address_components.slice(*ADDRESS_COMPONENTS)
  end

  def normalize
    normalized_country = COUNTRY_LOOKUP[@address_components[:country]] || @address_components[:country]
    
    normalized_postal_code = if @address_components[:postal_code]
      @address_components[:postal_code].gsub(/\s+/, '').upcase
    end

    normalized_street = if @address_components[:street]
      remove_special_chars = @address_components[:street]
        .upcase
        .gsub(/[^\w\s]/, '')


      with_replacements = remove_special_chars.gsub(/\b(\w+)\b/) { |match| ABBREV_LOOKUP[match] || match }.capitalize if remove_special_chars
      with_replacements
    end

    components = @address_components.merge({
      street: normalized_street,
      country: normalized_country,
      postal_code: normalized_postal_code
    })

    return Address.new(components)
  end

  def [](sym)
    @address_components[sym]
  end

  def to_s(keys = ADDRESS_COMPONENTS)
    keys.map {|k| @address_components[k] }.compact.join(', ') || ""
  end

  def lexical_distance(components0, compare_keys = ADDRESS_COMPONENTS)
    street_distance = Levenshtein.distance(self.normalize[:street] || "", components0.normalize[:street] || "")
    tail_distance = Levenshtein.distance(self.normalize.to_s(compare_keys - [:street]),
                                         components0.normalize.to_s(compare_keys - [:street]))
  
    total = street_distance + (tail_distance * 0.5)
  end
end

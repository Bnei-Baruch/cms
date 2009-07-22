class Mainsites::Widgets::LanguageMenu < WidgetManager::Base

  def render_full
    select(:name => 'languages', :id=>"languagebar"){
      list_of_country
    }
  end
  
  def list_of_country
    llg = {
      -1 => ["Choose your language", ""],
      0 => ["Hebrew" , "http://www.kab.co.il"],
      1 => ["English", "http://www.kabbalah.info/"],
      2 => ["Russian", "http://www.kabbalah.info/rus"],
      3 => ["Spanish", "http://www.kabbalah.info/spanishkab"],
      4 => ["French", "http://www.kabbalah.info/fr"],
      5 => ["German", "http://german.kabbalah.info/"],
      6 => ["Arabic", "http://www.kabbalah.info/arabickab/index_arabic.htm"],
      7 => ["Greek", "http://www.kabbalah.info/greekab/index.htm"],
      8 => ["Georgian", "http://www.kabbalah.info/geokab/index_geo.htm"],
      9 => ["Ukranian", "http://www.kabbalah.info/ukrkab/index_ukr.htm"],
      10 => ["Turkish", "http://www.kabbalah.info/turkishkab"],
      11 => ["Lithunian", "http://www.kabbalah.info/litakab/index_lita.htm"],
      12 => ["Latvian", "http://www.kabbalah.info/latvikab/index_lat.htm"],
      13 => ["Macedonian", "http://www.kabbalah.info/macedonian"],
      14 => ["Nederlands", "http://www.kabbalah.info/dutchkab/index.html"],
      15 => ["Polish", "http://www.kabbala.com.pl/index.php"],
      16 => ["Portugese", "http://www.kabbalah.info/brazilkab/index_braz.htm"],
      17 => ["Romanian", "http://www.kabbalah.info/romkab/index.htm"],
      18 => ["Korean", "http://www.kabbalah.info/korean"],
      19 => ["Chinese", "http://www.kabbalah.info/cn"],
      20 => ["Filipino" , "http://www.kabbalah.info/tagalog"],
      21 => ["Czech" , "http://www.kabbalah.info/czech"],
      22 => ["Serbian" , "http://www.kabbalah.info/serbian"],
      23 => ["Yiddish" , "http://www.kabbalah.info/yidishkab/index_yidish.htm"]}
    llg.sort.each{ |e|
      option(:value => e[1][1]){ text _((e[1][0].downcase).gsub(" ", "").to_sym)}
    }
  end

end
class Hebmain::Widgets::Tree < Widget::Base
  def render
    ul {
      li 'קבלה ואקטואליה'
      li 'קמפוס קבלה'
      li(:class => 'submenu') {
        text 'חגים בקבלה'
        ul {
          li 'ראש השנה', :class => 'final'
          li 'יום כיפור'
          li 'סוכות'
          li 'חנוכה'
          li 'ט”ו בשבט', :class => 'selected'
          li 'פורים'
          li 'פסח'
          li 'ל”ג בעומר'
          li 'שבועות'
          li 'ט’ באב'
        }
      }
      li 'מסע בין כוכבים'
      li 'פותחים את הזוהר'
      li 'בעקבות לבי'
      li 'מושגים בקבלה'
      li 'טורים וסיפורים'
    }
  end
end
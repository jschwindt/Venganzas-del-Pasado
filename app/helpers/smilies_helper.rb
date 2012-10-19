module SmiliesHelper

  TRANSLATIONS = {
    ':mrgreen:' => 'mrgreen',
    ':neutral:' => 'neutral',
    ':twisted:' => 'twisted',
      ':arrow:' => 'arrow',
      ':shock:' => 'eek',
      ':smile:' => 'smile',
        ':???:' => 'confused',
       ':cool:' => 'cool',
       ':evil:' => 'evil',
       ':grin:' => 'biggrin',
       ':idea:' => 'idea',
       ':oops:' => 'redface',
       ':razz:' => 'razz',
       ':roll:' => 'rolleyes',
       ':wink:' => 'wink',
        ':cry:' => 'cry',
        ':eek:' => 'surprised',
        ':lol:' => 'lol',
        ':mad:' => 'mad',
        ':sad:' => 'sad',
          '8-)' => 'cool',
          '8-O' => 'eek',
          ':-(' => 'sad',
          ':-)' => 'smile',
          ':-?' => 'confused',
          ':-D' => 'biggrin',
          ':-P' => 'razz',
          ':-o' => 'surprised',
          ':-x' => 'mad',
          ':-|' => 'neutral',
          ';-)' => 'wink',
           '8)' => 'cool',
           '8O' => 'eek',
           ':(' => 'sad',
           ':)' => 'smile',
           ':?' => 'confused',
           ':D' => 'biggrin',
           ':P' => 'razz',
           ':o' => 'surprised',
           ':x' => 'mad',
           ':|' => 'neutral',
           ';)' => 'wink',
          ':!:' => 'exclaim',
          ':?:' => 'question',
  }

  REGEXP = /(?m-ix:(?:\s|^);(?:\-\)|\))|(?:\s|^):(?:\||x|wink:|twisted:|smile:|shock:|sad:|roll:|razz:|oops:|o|neutral:|mrgreen:|mad:|lol:|idea:|grin:|evil:|eek:|cry:|cool:|arrow:|P|D|\?\?\?:|\?:|\?|\-\||\-x|\-o|\-P|\-D|\-\?|\-\)|\-\(|\)|\(|!:)|(?:\s|^)8(?:O|\-O|\-\)|\))(?:\s|$))/m

  def replace_smileys(text)
    output = ''
    text.split(/(<.*?>)/, -1).each do |content|
      if ((content.length > 0) && ('<' != content[0]))
        content = content.gsub REGEXP do |smiley|
          smiley.strip!
          return '' if smiley.nil?
          ' ' + content_tag(:span, smiley, :class => "smiley "+TRANSLATIONS[smiley])
        end
      end
      output << content
    end
    output.html_safe
  end

## Lets leave this here just in case...
#
#  private
#
#  def generate_regexp
#    regexp = '(?:\s|^)'
#
#    subchar = ''
#
#    TRANSLATIONS.sort.reverse_each do |smiley, img|
#      firstchar = smiley[0]
#      rest = smiley[1..smiley.length]
#
#      if (firstchar != subchar)
#        if (subchar != '')
#          regexp << ')|(?:\s|^)'
#        end
#        subchar = firstchar
#        regexp << Regexp.escape(firstchar) + '(?:'
#      else
#        regexp << '|'
#      end
#      regexp << Regexp.escape(rest)
#    end
#
#    regexp << ')(?:\s|$)'
#
#    Regexp.new(regexp, Regexp::MULTILINE)
#  end

end

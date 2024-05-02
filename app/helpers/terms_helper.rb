module TermsHelper
  def dict_groups
    [
      "#",
      "A - B",
      "C - D",
      "E - F",
      "G - H",
      "I - J",
      "K - L",
      "M - N",
      "O - P",
      "Q - R",
      "S - T",
      "U - V",
      "W - X",
      "Y - Z"
    ]
  end

  def dict_group(title)
    first_char = title[0]&.upcase

    return "#" unless first_char.match?(/[A-Z]/)

    group_index = (first_char.ord - "A".ord) / 2

    dict_groups[group_index + 1]
  end
end

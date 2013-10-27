class String
  def norway_to_english_month
    self.gsub(/januar|februar|mars|april|mai|juni|juli|august|september|oktober|november|desember/, 'januar' => 'January', 'februar' => 'February', 'mars' => 'March', 'april' => 'April', 'mai' => 'May', 'juni' => 'June', 'juli' => 'July', 'august' => 'August', 'september' => 'September', 'oktober' => 'October', 'november' => 'November', 'desember' => 'December')
  end
end
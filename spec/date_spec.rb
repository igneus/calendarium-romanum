# expectations concerning the Ruby implementation
describe Date do
  describe 'substraction' do
    it 'returns Rational' do
      date_diff = Date.new(2013,5,5) - Date.new(2013,5,1)
      expect(date_diff).to be_a Rational
      expect(date_diff.numerator).to eq 4
    end
  end
end

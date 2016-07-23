require_relative '../src/case_class'

describe CaseClass do
  let(:point_class) { described_class.new(Object, :x, :y) }
  context 'An instance of it' do
    it 'can be instantiated' do
      expect(CaseClass.new(Object)).to respond_to :new
    end
  end
  it 'responds to all the messages a class responds' do
    expect(CaseClass.new(Object).methods).to include *Class.new.methods
  end
  context 'An instantiated object' do
    let(:point) {point_class.new(x: 1,y: 10)}
    it 'needs be instantiated with all its parameters' do
      expect{point_class.new(x: 1, y:2)}.not_to raise_error
      expect{point_class.new(x: 1)}.to raise_error ArgumentError
    end
    it 'is immutable' do
      expect{point.instance_variable_set(:@x, 5)}.to raise_error RuntimeError
    end
    it 'its values are accessible' do
      expect(point.x).to be 1
      expect(point.y).to be 10
    end
  end
  context 'Two instantiated objects' do
    context 'of the same case class' do
      context 'with the same values' do
        let(:point_a) { point_class.new(x: 1,y: 1) }
        let(:point_b) { point_class.new(x: 1,y: 1) }
        it 'are the same' do
          expect(point_a).to be point_b
        end
        it 'are equal' do
          expect(point_a).to eq point_b
        end
        it 'have the same hash' do
          expect(point_a.hash).to eq point_b.hash
        end
        it 'should be able to be used as a hash key' do
          a_hash = { point_a => 5}
          expect(a_hash[point_b]).to eq 5
        end
      end
    end
  end
end
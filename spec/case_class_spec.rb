require_relative '../src/case_class'

describe CaseClass do
  class Point
    case_class with: [:x, :y]
  end

  let(:point_class) { Point }

  context 'An instantiated object' do
    let(:point) {point_class.new(x: 1,y: 10)}

    context 'when instantiating it' do
      it 'needs to be instantiated with all its parameters' do
        expect{point_class.new(x: 1, y:2)}.not_to raise_error
        expect{point_class.new(x: 1)}.to raise_error ArgumentError
      end

      context 'by using the class name as a method' do
        it 'can be instantiated by passing a hash' do
          expect(Point(x: 1, y: 10)).to eq point
        end

        it 'can be instantiated by passing varargs in order' do
          expect(Point(1, 10)).to eq point
        end
      end
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
      context 'with different values' do
        it 'should have different hashes' do
          expect(Point(1, 1).hash).not_to eq(Point(1, 2).hash)
        end
      end
      context 'with the same values' do
        let(:point_a) { Point(x: 1, y: 1) }
        let(:point_b) { Point(x: 1, y: 1) }

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
    context 'of different classes' do
      class Rectangle
        case_class with: [:x, :y]
      end

      it 'should have a different hashes' do
        expect(Rectangle(1, 1).hash).not_to eq (Point(1, 1).hash)
      end
    end
  end
end
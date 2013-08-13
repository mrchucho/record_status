require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class MyRecord < Record
  attr_accessor :record_status, :type_code

  include RecordStatus
end

describe RecordStatus do

  describe 'default_scope_by_status' do
    context 'given default status codes' do
      before do
        MyRecord.default_scopes = []
        MyRecord.class_eval do
          default_scope_by_status :record_status, :active
        end
      end

      subject { MyRecord.new }

      it 'creates a default scope on the model' do
        expect(subject.class.default_scopes).to eq([[:where, ["record.record_status in (?)", ['A']]]])
      end

      context 'given option allow_nil: true' do
        before do
          MyRecord.default_scopes = []
          MyRecord.class_eval do
            default_scope_by_status :record_status, :active, allow_nil: true
          end
        end

        it 'creates a default scope on the model that checks for nil' do
          expect(subject.class.default_scopes).to eq([[:where, ["record.record_status in (?)", ['A', nil]]]])
        end
      end

      context 'given option allow_blank: true' do
        before do
          MyRecord.default_scopes = []
          MyRecord.class_eval do
            default_scope_by_status :record_status, :active, allow_blank: true
          end
        end

        it 'creates a default scope on the model that checks for nil' do
          expect(subject.class.default_scopes).to eq([[:where, ["record.record_status in (?)", ['A', '']]]])
        end
      end
    end

    context 'given multiple status names' do
      before do
        MyRecord.default_scopes = []
        MyRecord.class_eval do
          default_scope_by_status :record_status, [:active, :hidden]
        end
      end

      subject { MyRecord.new }

      it 'creates a default scope on the model' do
        expect(subject.class.default_scopes).to eq([[:where, ["record.record_status in (?)", ['A', 'H']]]])
      end
    end

    context 'given custom status codes' do
      before do
        MyRecord.default_scopes = []
        MyRecord.class_eval do
          default_scope_by_status :record_status, :private_practice, codes: {
            'P' => :private_practice,
            'G' => :group_practice,
            'H' => :hospital,
            'C' => :clinic,
            'O' => :home
          }
        end
      end

      subject { MyRecord.new }

      it 'creates a default scope on the model' do
        expect(subject.class.default_scopes).to eq([[:where, ["record.record_status in (?)", ['P']]]])
      end
    end
  end

  describe 'status' do
    context 'given an implicit field' do
      context 'given default status codes' do
        before do
          MyRecord.scopes = []
          MyRecord.class_eval do
            status :status
          end
        end

        subject { MyRecord.new }

        it 'sets a scope for each status value' do
          expect(subject.class.scopes).to include([:active, [:where, {status: 'A'}]])
        end

        describe 'status reader' do
          context 'given the associated attribute is set to "D"' do
            before do
              subject[:status] = 'D'
            end

            it 'returns the descriptive name :deleted' do
              expect(subject.status).to eq(:deleted)
            end
          end
        end

        describe 'status writer' do
          context 'given the descriptive name :active' do
            before do
              subject.status = :active
            end

            it 'sets the associated attribute with the short code "A"' do
              expect(subject[:status]).to eq('A')
            end
          end
        end
      end
    end

    context 'given an explicit field' do
      context 'given default status codes' do
        before do
          MyRecord.scopes = []
          MyRecord.class_eval do
            status :status, field: :record_status
          end
        end

        subject { MyRecord.new }

        it 'sets a scope for each status value' do
          expect(subject.class.scopes).to have(6).scopes
          expect(subject.class.scopes).to include([:active,                   [:where, {record_status: 'A'}]])
          expect(subject.class.scopes).to include([:hidden,                   [:where, {record_status: 'H'}]])
          expect(subject.class.scopes).to include([:administratively_deleted, [:where, {record_status: 'X'}]])
        end

        describe 'status reader' do
          context 'given the associated attribute is set to "D"' do
            before do
              subject[:record_status] = 'D'
            end

            it 'returns the descriptive name :deleted' do
              expect(subject.status).to eq(:deleted)
            end
          end

          context 'given the associated attribute is set to " D "' do
            before do
              subject[:record_status] = ' D '
            end

            it 'returns the descriptive name :deleted' do
              expect(subject.status).to eq(:deleted)
            end
          end

          context 'given the associated attribute is set to nil' do
            before do
              subject[:record_status] = nil
            end

            it 'returns nil' do
              expect(subject.status).to be_nil
            end
          end

          context 'given a default value' do
            before do
              MyRecord.scopes = []
              MyRecord.class_eval do
                status :status, field: :record_status, default: :active
              end
            end

            context 'given the associated attribute is set to nil' do
              before do
                subject[:record_status] = nil
              end

              it 'returns the default value :active' do
                expect(subject.status).to eq(:active)
              end
            end
          end
        end

        describe 'status writer' do
          context 'given the descriptive name :expired' do
            before do
              subject.status = :expired
            end

            it 'sets the associated attribute with the short code "E"' do
              expect(subject[:record_status]).to eq('E')
            end
          end

          context 'given an actual column value "R"' do
            before do
              subject.status = 'R'
            end

            it 'sets the associated attribute with the short code "R"' do
              expect(subject[:record_status]).to eq('R')
            end
          end

          context 'given an actual column value " R "' do
            before do
              subject.status = ' R '
            end

            it 'sets the associated attribute with the short code "R"' do
              expect(subject[:record_status]).to eq('R')
            end
          end

          context 'given a bad value' do
            it 'raises an exception' do
              expect(lambda { subject.status = :foo }).to raise_exception(ArgumentError)
            end
          end
        end
      end

      context 'given custom status codes' do
        before do
          MyRecord.scopes = []
          MyRecord.class_eval do
            status :type, field: :type_code, codes: {
              'P' => :private_practice,
              'G' => :group_practice,
              'H' => :hospital,
              'C' => 'clinic',
              'O' => :home
            }
          end
        end

        subject { MyRecord.new }

        it 'sets a scope for each status value' do
          expect(subject.class.scopes).to include([:private_practice, [:where, {type_code: 'P'}]])
        end

        describe 'status reader' do
          context 'given the associated attribute is set to "G"' do
            before do
              subject[:type_code] = 'G'
            end

            it 'returns the descriptive name :group_practice' do
              expect(subject.type).to eq(:group_practice)
            end
          end
        end

        describe 'status writer' do
          context 'given the descriptive name :hospital' do
            before do
              subject.type = :hospital
            end

            it 'sets the associated attribute with the short code "H"' do
              expect(subject[:type_code]).to eq('H')
            end
          end

          context 'given the descriptive name clinic' do
            before do
              subject.type = 'clinic'
            end

            it 'sets the associated attribute with the short code "C"' do
              expect(subject[:type_code]).to eq('C')
            end
          end
        end
      end
    end
  end
end

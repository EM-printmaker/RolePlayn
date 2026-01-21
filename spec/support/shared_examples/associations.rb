# belongs_to
RSpec.shared_examples "belongs_to_association" do |association_name, model_class|
  let(:parent) { subject.send(association_name) }
  let(:foreign_key) { "#{association_name}_id" }

  it "#{association_name}に正しく紐づいており、外部キーが一致すること" do
    expect(parent).to be_a(model_class)
    expect(subject.send(foreign_key)).to eq parent.id
  end
end

# has_many
RSpec.shared_examples "has_many_association" do |association_name, factory_name, parent_name|
  it "#{association_name}の中に期待するデータが含まれていること" do
    target = create(factory_name, parent_name => subject)

    expect(subject.send(association_name)).to include target
  end
end

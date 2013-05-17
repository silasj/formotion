describe "Form Resetting" do

  it "resets from App::Persistence if there is a persist_key" do
    key = "test_#{rand(255)}"
    App::Persistence["FORMOTION_#{key}"] = nil
    App::Persistence["FORMOTION_#{key}_ORIGINAL"] = nil
    f = Formotion::Form.new({
      persist_as: key,
      sections: [
        rows: [ {
            key: "first",
            type: "string",
            value: "initial value"
          }
        ]
      ]
    })

    f.save

    r = f.sections[0].rows[0]
    r.value = "new value"

    saved = f.send(:load_state)
    saved["first"] == r.value

    f.reset
    r.value.should == "initial value"
  end

  it "resets from the passed in data if there is no persist_key" do
    f = Formotion::Form.new({
      sections: [
        rows: [ {
            key: "first",
            type: "string",
            value: "initial value"
          }
        ]
      ]
    })

    r = f.sections[0].rows[0]
    r.value = "new value"

    f.reset
    r.value.should == "initial value"
  end

  it "works with subforms" do
    hash = {
      sections: [
        rows: [ {
            key: :subform,
            type: :subform,
            title: "Subform",
            subform: {
              title: "New Page",
              sections: [
                rows: [{
                  key: "second",
                  type: "string",
                  value: "initial value"
                }]
              ]
            }
          }
        ]
      ]
    }
    f = Formotion::Form.new(hash)
    f.to_hash.should == hash

    r = f.sections[0].rows[0].subform.to_form.sections[0].rows[0]
    r.value = "new value"

    f.reset
    r.value.should == "initial value"
  end
end
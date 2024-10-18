tableextension 70101 EricoCustomer extends Customer
{
    fields
    {
        field(70000; "Customer Statement Email"; Text[100])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = EMail;

            trigger OnValidate()
            begin
                ValidateEmail();
            end;
        }
    }



    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    local procedure ValidateEmail()
    var
        MailManagement: Codeunit "Mail Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then
            exit;

        if "Customer Statement Email" = '' then
            exit;
        MailManagement.CheckValidEmailAddresses("Customer Statement Email");
    end;

    var
        myInt: Integer;
}
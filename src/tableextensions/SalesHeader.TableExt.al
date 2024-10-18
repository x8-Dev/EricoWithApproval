tableextension 70102 EricoSalesHeader extends "Sales Header"
{
    fields
    {
        field(70101; "Due Exceed Status"; Option)
        {
            OptionMembers = " ","Approved","Pending","Rejected";
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

    var
        myInt: Integer;
}
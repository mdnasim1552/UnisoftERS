<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ExistingPatients.aspx.vb" Inherits="UnisoftERS.ExistingPatients" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Duplicate patient(s) found</title>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <script type="text/javascript">
            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow;
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow;
                return oWindow;
            }

            function CloseDialog() {
                GetRadWindow().close();
            }
        </script>

        <fieldset>
            <legend>Existing Patients</legend>
            <p>
                The following patient(s) already exists. Select your intended patient or cancel to continue adding.
            </p>
            <telerik:RadGrid ID="PatientsListGrid" OnItemDataBound="PatientsListGrid_ItemDataBound" runat="server" RenderMode="Lightweight" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                Skin="Metro" PageSize="25" AllowPaging="true" Style="margin-bottom: 10px; width: 100%; height: 170px;">
                <HeaderStyle Font-Bold="true" />
                <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="PatientId" DataKeyNames="PatientId" TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass">
                    <Columns>
                        <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="75px">
                            <ItemTemplate>
                                <asp:LinkButton ID="SelectPatientLinkButton" runat="server" Text="Select" ToolTip="Select patient" Font-Italic="true"></asp:LinkButton>
                                &nbsp;&nbsp;
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <telerik:GridBoundColumn DataField="FullName" HeaderText="Name" SortExpression="FullName" ItemStyle-Wrap="true" />
                        <telerik:GridBoundColumn DataField="NHSNo" HeaderText="NHS No" SortExpression="NHSNo" ItemStyle-Wrap="true" />
                        <telerik:GridBoundColumn DataField="Address" HeaderText="Address" SortExpression="Address" ItemStyle-Wrap="false" />
                        <telerik:GridBoundColumn DataField="Postcode" HeaderText="Postcode" SortExpression="Postcode" ItemStyle-Wrap="true" />
                    </Columns>
                    <NoRecordsTemplate>
                        <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv">
                            No data.
                        </div>
                    </NoRecordsTemplate>
                </MasterTableView>
                <PagerStyle Mode="NumericPages" AlwaysVisible="false" />
                <ClientSettings>
                    <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                </ClientSettings>
            </telerik:RadGrid>
        </fieldset>
        <div class="divButtons">
            <telerik:RadButton ID="CloseAndContinue" runat="server" Text="Close & Continue" OnClientClicked="CloseDialog" AutoPostBack="false" />
        </div>

    </form>
</body>
</html>

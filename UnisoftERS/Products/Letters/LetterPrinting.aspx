<%@ Page Language="vb" MasterPageFile="~/Templates/scheduler.master" AutoEventWireup="false" CodeBehind="LetterPrinting.aspx.vb" Inherits="UnisoftERS.LetterPrinting" %>

<asp:Content ID="MainBodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
      <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            function OpenPDF() {
                window.open('DisplayAndPrintPDF.aspx',"_blank");
            }

            function ShowNoSelectMessage() {
                alert("Please select one or more row(s) to print");
            }
            function OnRowDblClick(sender, eventArgs) {
            
                window.location.href = "EditLetter.aspx?LetterQueueId=" + eventArgs.getDataKeyValue("LetterQueueId") + "&AppointmentStatusId=" + eventArgs.getDataKeyValue("AppointmentStatusId") + "&OperationalHospitalId=" + eventArgs.getDataKeyValue("OperationalHospitalId") + "&Edited=" + eventArgs.getDataKeyValue("Edited")+ "&Printed=" + eventArgs.getDataKeyValue("Printed");
            }
        </script>
    </telerik:RadScriptBlock>
       <telerik:RadNotification ID="LetterPrintRadNotification" runat="server" VisibleOnPageLoad="false" Height="170px" CssClass="rad-window-popup" ShowCloseButton="true" Skin="Metro" Title="Booking error" AutoCloseDelay="0" />

    <br />
  
    Trust:&nbsp;<telerik:RadDropDownList ID="TrustDropDownList"  CssClass="filterDDL" DataTextField="TrustName" DataValueField="TrustId" runat="server" Skin="Metro" Width="150px" AutoPostBack="true" OnSelectedIndexChanged="TrustDropDownList_SelectedIndexChanged" />

    Hospital:&nbsp;<telerik:RadDropDownList ID="HospitalDropDownList" CssClass="filterDDL" runat="server" Width="150" DataTextField="HospitalName" AutoPostBack="true" DataValueField="OperatingHospitalID" OnSelectedIndexChanged="HospitalDropDownList_SelectedIndexChanged" />

    Appoint. Status:&nbsp;<telerik:RadDropDownList ID="AppointmentStatusDropDownList" CssClass="filterDDL" runat="server" Width="150" DataTextField="LetterName" AutoPostBack="true" DataValueField="AppointmentStatusId"  OnSelectedIndexChanged="AppointmentStatusDropDownList_SelectedIndexChanged" />


    <telerik:RadDatePicker RenderMode="Lightweight" ID="StartDate" Width="149px" Height="25px" runat="server" DateInput-Label="From:" ShowPopupOnFocus="true">
    </telerik:RadDatePicker>
    <telerik:RadDatePicker RenderMode="Lightweight" ID="EndDate" Width="131px" Height="25px" runat="server" DateInput-Label="To:" ShowPopupOnFocus="true">
    </telerik:RadDatePicker>
    Hospital No.:&nbsp; <telerik:RadTextBox RenderMode="Lightweight" ID="HospitalNumber" Width="120px" runat="server"  AutoPostBack="true"></telerik:RadTextBox>

    <telerik:RadButton RenderMode="Lightweight" ID="SearchButton" runat="server" Text="Search" Width="60px" OnClick="SearchButton_Click"></telerik:RadButton>
    <telerik:RadLabel runat="server" AssociatedControlID="ViewAllCheckbox" RenderMode="Lightweight"  Text="Show Printed:"></telerik:RadLabel>
    <telerik:RadCheckBox RenderMode="Lightweight" ID="ViewAllCheckbox" runat="server"  Width="30px" OnCheckedChanged="ViewAllCheckbox_CheckedChanged" AutoPostBack="true"></telerik:RadCheckBox>
 
      <telerik:RadButton RenderMode="Lightweight" ID="Print" runat="server" Text="Print" EnableViewState="false" OnClick="PrintButton_Click" >
                                <Icon SecondaryIconCssClass="rbPrint" ></Icon>
                            </telerik:RadButton>

    <telerik:RadGrid ID="LetterQueueGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
        AllowAutomaticDeletes="True" AutoSizeColumnsMode="Fill" AllowSorting="true"  RenderMode="Lightweight"
        Skin="Metro" GridLines="None" PageSize="15" AllowPaging="true" OnNeedDataSource="LetterQueueGrid_NeedDataSource" ExportSettings-IgnorePaging="true"
        OnItemCommand="LetterQueueGrid_ItemCommand" OnItemDataBound="LetterQueueGrid_ItemDataBound" CssClass="WrkGridClass">
        <HeaderStyle Font-Bold="true" BackColor="#25A0DA" />
        <CommandItemStyle BackColor="WhiteSmoke" />
        <MasterTableView ShowHeadersWhenNoRecords="true" TableLayout="Fixed" CssClass="MasterClass" DataKeyNames="LetterQueueId,AppointmentStatusId,OperationalHospitalId,AppointmentId" ClientDataKeyNames="LetterQueueId,AppointmentStatusId,OperationalHospitalId,AppointmentId,Edited,Printed"
            GridLines="None" ItemStyle-Height="28" AlternatingItemStyle-Height="28" AllowFilteringByColumn="false" AllowPaging="false">

            <Columns>
                <telerik:GridTemplateColumn UniqueName="LetterQueueIdCheckBoxTemplateColumn" HeaderStyle-Width="60px">
                    <ItemTemplate>
                        <asp:CheckBox ID="LetterQueueId" runat="server" OnCheckedChanged="ToggleRowSelection"
                            AutoPostBack="True" />
                    </ItemTemplate>
                    <HeaderTemplate>
                        <asp:CheckBox ID="LetterQueueIdheaderChkbox"  Text="Print All" runat="server" OnCheckedChanged="ToggleSelectedState"
                            AutoPostBack="True" />
                    </HeaderTemplate>
                </telerik:GridTemplateColumn>
                <telerik:GridTemplateColumn UniqueName="AdditionalDocumentCheckBoxTemplateColumn" HeaderStyle-Width="70px">
                    <ItemTemplate>
                        <asp:CheckBox ID="AdditionalDocument" runat="server" OnCheckedChanged="AdditionalDocsToggleRowSelection"
                            AutoPostBack="True" />
                    </ItemTemplate>
                    <HeaderTemplate>
                        <asp:CheckBox ID="AdditionalDocumentheaderChkbox" Text ="Addi. Docs" runat="server" OnCheckedChanged="AdditionalDocsToggleSelectedState"
                            AutoPostBack="True" />
                    </HeaderTemplate>
                </telerik:GridTemplateColumn>
            <telerik:GridBoundColumn DataField="Forename" HeaderText="Forename" SortExpression="Forename" HeaderStyle-Width="60px">
            </telerik:GridBoundColumn>
            <telerik:GridBoundColumn DataField="Surname" HeaderText="Surname" SortExpression="Surname" AllowFiltering="true" HeaderStyle-Width="60px">
            </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="HospitalNumber" HeaderText="HospitalNumber" SortExpression="HospitalNumber" HeaderStyle-Width="70px">
            </telerik:GridBoundColumn>
            <telerik:GridBoundColumn DataField="NHSNo" HeaderText="NHS No" SortExpression="NHSNo" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
            </telerik:GridBoundColumn>
            <telerik:GridBoundColumn DataField="DescriptionForLetter" HeaderText="Appointment Status" SortExpression="DescriptionForLetter" HeaderStyle-Width="100px">
            </telerik:GridBoundColumn>
               <telerik:GridBoundColumn DataField="Edited" HeaderText="Edited" SortExpression="Edited" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
            </telerik:GridBoundColumn>
            <telerik:GridBoundColumn DataField="Printed" HeaderText="Printed" SortExpression="Printed" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
            </telerik:GridBoundColumn>
              <telerik:GridBoundColumn DataField="EditedAfterPrint" HeaderText="Edited After Print" SortExpression="EditedAfterPrint" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
            </telerik:GridBoundColumn>
            <telerik:GridBoundColumn DataField="whencreated" HeaderText="Created Date" SortExpression="whencreated" HeaderStyle-Width="70px">    </telerik:GridBoundColumn>
            <telerik:GridBoundColumn DataField="AppointmentDate" HeaderText="Appointment Date" SortExpression="AppointmentDate" HeaderStyle-Width="70px">    </telerik:GridBoundColumn>
            <telerik:GridBoundColumn DataField="WhoEdited" HeaderText="Last Editded By" SortExpression="WhoEdited" HeaderStyle-Width="60px">
            </telerik:GridBoundColumn>
            <telerik:GridBoundColumn DataField="WhoPrinted" HeaderText="Last Printed By" SortExpression="WhoPrinted" HeaderStyle-Width="60px">
            </telerik:GridBoundColumn>
            <telerik:GridBoundColumn DataField="PrintCount" HeaderText="Times Printed" SortExpression="PrintCount" HeaderStyle-Width="30px">
            </telerik:GridBoundColumn>
            </Columns>
                    <NoRecordsTemplate>
                        <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;">
                            No Appointment found.
                        </div>
                    </NoRecordsTemplate>
        </MasterTableView>
        <PagerStyle Mode="NextPrevAndNumeric" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; Patients {2} to {3} of {5}"
            AlwaysVisible="true" BackColor="#f9f9f9" />
        <GroupingSettings CaseSensitive="false" CollapseAllTooltip="Collapse all groups"></GroupingSettings>
        <ClientSettings EnableRowHoverStyle="true">
            <ClientEvents OnRowDblClick="OnRowDblClick" />
            <Resizing AllowColumnResize="true" ResizeGridOnColumnResize="true" AllowResizeToFit="true" />
            <Selecting AllowRowSelect="true" />

            <Scrolling AllowScroll="true" UseStaticHeaders="true" />
        </ClientSettings>
        <HeaderStyle BackColor="#f4f7f9" Font-Bold="true" Height="10" />
        <SortingSettings SortedBackColor="ControlLight" />
    </telerik:RadGrid>


    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
        <script type="text/javascript">

</script>
    </telerik:RadCodeBlock>
</asp:Content>

<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Comfort.aspx.vb" Inherits="UnisoftERS.Comfort" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
        </telerik:RadAjaxManager>
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
            <Scripts>
                <asp:ScriptReference Assembly="Telerik.Web.UI" Name="Telerik.Web.UI.Common.Core.js">
                </asp:ScriptReference>
                <asp:ScriptReference Assembly="Telerik.Web.UI" Name="Telerik.Web.UI.Common.jQuery.js">
                </asp:ScriptReference>
                <asp:ScriptReference Assembly="Telerik.Web.UI" Name="Telerik.Web.UI.Common.jQueryInclude.js">
                </asp:ScriptReference>
            </Scripts>
        </telerik:RadScriptManager>
    <div>
    
        <telerik:RadPivotGrid RenderMode="Lightweight" ID="RadPivotGrid1" runat="server" AllowPaging="True" PageSize="10" AllowSorting="True" DataMember="DefaultView" DataSourceID="SqlDataSource1" Skin="Office2007" Height="1000px" ClientSettings-Resizing-AllowColumnResize="true" ColumnHeaderTableLayout="Fixed">
            <ClientSettings Scrolling-AllowVerticalScroll="true" EnableFieldsDragDrop="true">
<Scrolling AllowVerticalScroll="True"></Scrolling>
                <Resizing AllowColumnResize="True" />
            </ClientSettings>
            <DataCellStyle Width="100px" />
<PagerStyle ChangePageSizeButtonToolTip="Change Page Size" PageSizeControlType="RadComboBox" ></PagerStyle>
            <Fields>
                <telerik:PivotGridReportFilterField ZoneIndex="0" DataField="ProcedureType" Caption="Procedure Type" UniqueName="ProcedureType"></telerik:PivotGridReportFilterField>
                <telerik:PivotGridReportFilterField ZoneIndex="1" DataField="ConsultantType" Caption="Consultant Type" UniqueName="ConsultantType"></telerik:PivotGridReportFilterField>
                <telerik:PivotGridReportFilterField ZoneIndex="2" DataField="Gender" Caption="Gender" UniqueName="Gender"></telerik:PivotGridReportFilterField>
                <telerik:PivotGridRowField ZoneIndex="0" DataField="ConsultantName" Caption="Consultant Name" UniqueName="ConsultantName"></telerik:PivotGridRowField>
                <telerik:PivotGridRowField ZoneIndex="1" DataField="Patient" Caption="Patient" UniqueName="Patient"></telerik:PivotGridRowField>
                <telerik:PivotGridRowField ZoneIndex="2" DataField="CNN" Caption="Case note No" UniqueName="CNN"></telerik:PivotGridRowField>
                <telerik:PivotGridColumnField ZoneIndex="0" DataField="Period" Caption="Period" UniqueName="Period"></telerik:PivotGridColumnField>
                <telerik:PivotGridAggregateField ZoneIndex="0" DataField="Age" Caption="Age" UniqueName="Age" Aggregate="Average"></telerik:PivotGridAggregateField>
            </Fields>
        </telerik:RadPivotGrid>
    
    </div>
        <asp:ObjectDataSource ID="SqlDataSource1" runat="server" SelectMethod="GetCube01" TypeName="UnisoftERS.Reports">
        </asp:ObjectDataSource>
    </form>
</body>
</html>

<%@ Page Language="VB" MasterPageFile="~/Templates/ProcedureMaster.Master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_OtherData_PrintProcedure" CodeBehind="PrintProcedure.aspx.vb" %>

<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>

<%@ Register Src="~/UserControls/PrintInitiate.ascx" TagPrefix="unisoft" TagName="PrintInitiate" %>

<asp:Content ID="IDHead" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../../Scripts/raphael-min.js"></script>
    <script type="text/javascript" src="../../../Scripts/raphael.export.js"></script>
    <script type="text/javascript" src="../../../Scripts/rgbcolor.js"></script>
    <script type="text/javascript" src="../../../Scripts/canvg.js"></script>
    <script type="text/javascript" src="../../../Scripts/qTip/jquery.qtip.js"></script>
    <script type="text/javascript" src="../../../Scripts/diagramReport.js"></script>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            $(document).ready(function () {
                var isChecked = $('#<%= ProcNotCarriedOutCheckBox.ClientID %>').is(':checked');
                if (isChecked){
                    enableDisableProcedureButton(isChecked);
                }
                $find("<%= RadFormDecorator1.ClientID %>").decorate();
            });            
        </script>
    </telerik:RadScriptBlock>
</asp:Content>


<asp:Content ID="IDBody" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">
    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
       <script type="text/javascript">
           newProcedureInitiated = true;
       </script>
    </telerik:RadCodeBlock>
     
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="divPrintInitiate" Skin="Web20" />
    <div id="divPrintInitiate" runat="server">
        <unisoft:PrintInitiate runat="server" ID="PrintInitiateUserControl" />
    </div>
    <div style="display:none;">
        <asp:CheckBox ID="ProcNotCarriedOutCheckBox" CssClass="cancelled-proc-cb" runat="server" Text="Procedure not carried out" AutoPostBack="false" />
    </div>
</asp:Content>

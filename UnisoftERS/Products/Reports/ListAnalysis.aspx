<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/Reports.Master"
    CodeBehind="ListAnalysis.aspx.vb" Inherits="UnisoftERS.ListAnalysis"
    ValidateRequest="False" %>


<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>

<%@ Register TagPrefix="qsf" Namespace="Telerik.QuickStart" %>

<asp:Content ID="MainBodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">



    <%--<telerik:RadScriptManager runat="server" ID="RadScriptManager1" />--%>

    <telerik:RadSkinManager ID="RadSkinManager1" runat="server" ShowChooser="true" />

    <%--<div>

        <asp:ImageButton ID="ImageButton1" runat="server" ImageUrl="Images/Excel_HTML.png"
            OnClick="ImageButton_Click" AlternateText="Html" />

        <asp:ImageButton ID="ImageButton2" runat="server" ImageUrl="Images/Excel_ExcelML.png"
            OnClick="ImageButton_Click" AlternateText="ExcelML" />

        <asp:ImageButton ID="ImageButton3" runat="server" ImageUrl="Images/Excel_BIFF.png"
            OnClick="ImageButton_Click" AlternateText="Biff" />

        <asp:ImageButton ID="ImageButton4" runat="server" ImageUrl="Images/Excel_XLSX.png"
            OnClick="ImageButton_Click" AlternateText="Xlsx" />

    </div>--%>

    <div class="demo-container no-bg">

        <telerik:RadGrid RenderMode="Lightweight" ID="RadGrid1" runat="server" DataSourceID="DSAdeTest" AllowPaging="false"
            OnItemCommand="RadGrid1_ItemCommand"
            PageSize="7" AutoGenerateColumns="false" OnExcelMLWorkBookCreated="RadGrid1_ExcelMLWorkBookCreated"
            OnItemCreated="RadGrid1_ItemCreated" OnHTMLExporting="RadGrid1_HtmlExporting"
            OnBiffExporting="RadGrid1_BiffExporting">

            <MasterTableView DataKeyNames="RowId" ClientDataKeyNames="RowId" CommandItemDisplay="TopAndBottom">
                <CommandItemSettings ShowExportToExcelButton="true" ShowAddNewRecordButton="false" ShowRefreshButton="true" />

                <Columns>
                    <telerik:GridBoundColumn DataField="ConsultantName" HeaderText="Consultant Name" HeaderStyle-Width="250px"
                        HeaderStyle-Font-Bold="true">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="PatientHospitalNumber" HeaderText="Patient Hospital Number" HeaderStyle-Width="200px"
                        HeaderStyle-Font-Bold="true">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="PatientName" HeaderText="Patient Name" HeaderStyle-Width="250px"
                        HeaderStyle-Font-Bold="true">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="ProcedureType" HeaderText="Procedure Type" HeaderStyle-Width="200px"
                        HeaderStyle-Font-Bold="true">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="ProcDay" HeaderText="Procedure Date" HeaderStyle-Width="250px" HeaderStyle-Font-Bold="true">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Assistant" HeaderText="Assistant" HeaderStyle-Width="250px" HeaderStyle-Font-Bold="true">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="PP_Indic" HeaderText="Indications" HeaderStyle-Width="250px" HeaderStyle-Font-Bold="true">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="PP_Thera" HeaderText="Therapies" HeaderStyle-Width="250px" HeaderStyle-Font-Bold="true">
                    </telerik:GridBoundColumn>
                </Columns>
            </MasterTableView>

        </telerik:RadGrid>

    </div>

    <%--<asp:SqlDataSource ID="SqlDataSource1" ConnectionString="<%$ ConnectionStrings:Gastro_DB %>"
        SelectCommand="SELECT * FROM ERS_ReportFilter" runat="server"></asp:SqlDataSource>--%>

        <<asp:ObjectDataSource ID="DSAdeTest" runat="server" SelectMethod="GetListAnalysis1" TypeName="UnisoftERS.Reports">
            <SelectParameters>
                <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                <asp:ControlParameter Name="IncludeIndications" DbType="String" ControlID="CheckBox1" ConvertEmptyStringToNull="true" />
                <asp:ControlParameter Name="IncludeTherapeutics" DbType="String" ControlID="CheckBox2" ConvertEmptyStringToNull="true" />
            </SelectParameters>
        </asp:ObjectDataSource>


    <%--<qsf:ConfiguratorPanel ID="ConfiguratorPanel1" runat="server">--%>

    <%-- <Views>--%>

    <%--  <qsf:View>--%>

    <%-- <ul class="fb-group">--%>

    <%--  <li>--%>

    <asp:CheckBox ID="CheckBox1" runat="server" Text="Disable Paging"></asp:CheckBox>

    <%--    </li>

                    <li>--%>

    <asp:CheckBox ID="CheckBox2" runat="server" Text="Apply Custom Styles"></asp:CheckBox>

    <%--   </li>

                </ul>--%>

    <%-- </qsf:View>--%>

    <%-- </Views>--%>

    <%--    </qsf:ConfiguratorPanel>--%>
</asp:Content>

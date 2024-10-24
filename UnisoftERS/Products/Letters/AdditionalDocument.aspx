<%@ Page Language="vb" MasterPageFile="~/Templates/scheduler.master" AutoEventWireup="false" CodeBehind="AdditionalDocument.aspx.vb" Inherits="UnisoftERS.AdditionalDocument" %>

<asp:content contentplaceholderid="HeadContentPlaceHolder" runat="server">
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
</asp:content>

<asp:Content ID="MainBodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
    <br />
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            function ShowMessage() {
                alert("please choose Procedure type");
            }
            function OpenPDF(documentId) {
                window.open('DownloadDocument.aspx?documentId=' + documentId, "_blank");
            }
            function DownloadPDF(documentId) {
                window.open('DownloadDocument.aspx?documentId=' + documentId, "_blank");
            }
            function OnRowDblClick(sender, eventArgs) {
            
                window.location.href = "AddAdditionalDocument.aspx?AdditionalDocumentId=" + eventArgs.getDataKeyValue("AdditionalDocumentId") ;
               }
        </script>
    </telerik:RadScriptBlock>
    <div id="ContentDiv">
        <div style="display:flex;justify-content:space-between">
            <div >
             Hospital:&nbsp;<telerik:RadDropDownList ID="HospitalDropDownList" CssClass="filterDDL" runat="server" Width="150" DataTextField="HospitalName" AutoPostBack="true" DataValueField="OperatingHospitalID" OnSelectedIndexChanged="HospitalDropDownList_SelectedIndexChanged" />

                 <telerik:RadButton ID="RadButton2" runat="server" Text="Add" Skin="Metro" OnClick="AddClick" Icon-PrimaryIconUrl="../../Images/icons/Create.png">
                 </telerik:RadButton>
            </div>
        </div>
        <br />
      
    

        <telerik:RadGrid ID="AdditionalDocumentListGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
            AllowAutomaticDeletes="True" AutoSizeColumnsMode="Fill" AllowSorting="true" Height="537" RenderMode="Lightweight"
            Skin="Metro" GridLines="None" PageSize="15" AllowPaging="true" OnItemDataBound="AdditionalDocumentListGrid_ItemDataBound" OnNeedDataSource="AdditionalDocumentListGrid_NeedDataSource" ExportSettings-IgnorePaging="true"
            CssClass="WrkGridClass" Font-Size="Small">
            <HeaderStyle Font-Bold="true" BackColor="#25A0DA" />
            <CommandItemStyle BackColor="WhiteSmoke" />
            <MasterTableView ShowHeadersWhenNoRecords="true" TableLayout="Fixed" CssClass="MasterClass" DataKeyNames="AdditionalDocumentId" ClientDataKeyNames="AdditionalDocumentId"
                GridLines="None" ItemStyle-Height="28" AlternatingItemStyle-Height="28" AllowFilteringByColumn="false" AllowPaging="false">

                <Columns>
                  <%--  <telerik:GridTemplateColumn UniqueName="AdditionalDocumentIdCheckBoxTemplateColumn" HeaderStyle-Width="20px">
                        <ItemTemplate>
                            <asp:CheckBox ID="AdditionalDocumentId" runat="server" OnCheckedChanged="ToggleRowSelection"
                                AutoPostBack="True" />
                        </ItemTemplate>
                        <HeaderTemplate>
                            <asp:CheckBox ID="AdditionalDocumentIdheaderChkbox" runat="server" OnCheckedChanged="ToggleSelectedState"
                                AutoPostBack="True" />
                        </HeaderTemplate>
                    </telerik:GridTemplateColumn>--%>

                    <telerik:GridImageColumn DataType="System.String" DataImageUrlFields="MimeIcon"
                        DataImageUrlFormatString="{0}" AlternateText="Customer image" DataAlternateTextField="ProcedureType"
                        ImageAlign="Middle" ImageHeight="20px" ImageWidth="20px" HeaderText="" HeaderStyle-Width="20px">
                    </telerik:GridImageColumn>
                      <telerik:GridBoundColumn DataField="HospitalName" HeaderText="Hospital Name" SortExpression="HospitalName" HeaderStyle-Width="130px">
                    </telerik:GridBoundColumn>
                       <telerik:GridBoundColumn DataField="DocumentName" HeaderText="Document Name" SortExpression="DocumentName" HeaderStyle-Width="130px">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="ProcedureName" HeaderText="Procedure Type" SortExpression="ProcedureName" HeaderStyle-Width="130px">
                   </telerik:GridBoundColumn>
                     <telerik:GridBoundColumn DataField="TherapeuticName" HeaderText="Therapeutic Name" SortExpression="TherapeuticName" HeaderStyle-Width="130px">
                    </telerik:GridBoundColumn>
                    <telerik:GridTemplateColumn DataField="AdditionalDocumentId" HeaderText="Download" SortExpression="AdditionalDocumentId" UniqueName="AdditionalDocumentId" HeaderStyle-Width="130px">
                        <ItemTemplate>
                              <telerik:RadButton Skin="Metro" ID="printitem" runat="server" CommandArgument='<%# Eval("AdditionalDocumentId") %>'  OnClick="lnkPrint_Click" Icon-PrimaryIconUrl="../../images/Icons/print.png">
                              
                            </telerik:RadButton>
                             <telerik:RadButton Skin="Metro" ID="downloaditem" runat="server"  CommandArgument='<%# Eval("AdditionalDocumentId") %>'  OnClick="lnkDownload_Click" Icon-PrimaryIconUrl="../../images/Icons/download.png">
                                
                            </telerik:RadButton>
                          
                        </ItemTemplate>
                        
                    </telerik:GridTemplateColumn>
                </Columns>
                <NoRecordsTemplate>
                    <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;">
                        No Document found.
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
    </div>

</asp:Content>

<%@ Page Language="vb" MasterPageFile="~/Templates/Unisoft.master" AutoEventWireup="false" CodeBehind="ListLetterTemplate.aspx.vb" Inherits="UnisoftERS.ListLetterTemplate" %>

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
            function OnRowDblClick(sender, eventArgs) {

                window.location.href = "LetterTemplate.aspx?LetterTypeId=" + eventArgs.getDataKeyValue("LetterTypeId");
            }
        </script>
    </telerik:RadScriptBlock>
    <div id="ContentDiv">
        <div style="display:flex;justify-content:space-between">
            <div >
             Hospital:&nbsp;<telerik:RadDropDownList ID="HospitalDropDownList" CssClass="filterDDL" runat="server" Width="150" DataTextField="HospitalName" AutoPostBack="true" DataValueField="OperatingHospitalID" OnSelectedIndexChanged="HospitalDropDownList_SelectedIndexChanged" />

                 <telerik:RadButton RenderMode="Lightweight" ID="RadButton2" runat="server" Text="Add Template" OnClick="AddClick">
                                <Icon SecondaryIconCssClass="rbAdd"></Icon>
                            </telerik:RadButton>
            </div>
       
            
         
        </div>
        <br />
      
    

        <telerik:RadGrid ID="TemplateListGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
            AllowAutomaticDeletes="True" AutoSizeColumnsMode="Fill" AllowSorting="true" Height="537" RenderMode="Lightweight"
            Skin="Metro" GridLines="None" PageSize="15" AllowPaging="true" OnItemDataBound="TemplateListGrid_ItemDataBound" OnNeedDataSource="TemplateListGrid_NeedDataSource" ExportSettings-IgnorePaging="true"
            CssClass="WrkGridClass">
            <HeaderStyle Font-Bold="true" BackColor="#25A0DA" />
            <CommandItemStyle BackColor="WhiteSmoke" />
            <MasterTableView ShowHeadersWhenNoRecords="true" TableLayout="Fixed" CssClass="MasterClass" DataKeyNames="LetterTypeId" ClientDataKeyNames="LetterTypeId"
                GridLines="None" ItemStyle-Height="28" AlternatingItemStyle-Height="28" AllowFilteringByColumn="false" AllowPaging="false">

                <Columns>
               

                    <telerik:GridImageColumn DataType="System.String" DataImageUrlFields="MimeIcon"
                        DataImageUrlFormatString="{0}" AlternateText="Customer image" DataAlternateTextField="LetterTypeId"
                        ImageAlign="Middle" ImageHeight="20px" ImageWidth="20px" HeaderText="" HeaderStyle-Width="20px">
                    </telerik:GridImageColumn>
                      <telerik:GridBoundColumn DataField="HospitalName" HeaderText="HospitalName" SortExpression="HospitalName" HeaderStyle-Width="130px">
                    </telerik:GridBoundColumn>
                       <telerik:GridBoundColumn DataField="LetterName" HeaderText="Template Name" SortExpression="AppointmentStatus" HeaderStyle-Width="130px">
                    </telerik:GridBoundColumn>
                   
                   
                </Columns>
                <NoRecordsTemplate>
                    <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;">
                        No Template found.
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

<%@ Page Language="VB" MasterPageFile="~/Templates/ProcedureMaster.Master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_OtherData_OGD_RX" Codebehind="Rx.aspx.vb" ValidateRequest="false" %>

<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>

<asp:Content ID="IDHead" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/Global.js"></script>
    <link href="../../../../Styles/Site.css" rel="stylesheet" />
    <script type="text/javascript">

        var medArr = [];
        var sVar;
        var sVar1;
        var sVar2;
        var sVar3;

        window.onbeforeunload = function (event) {
            document.getElementById("<%= SaveOnly.ClientID %>").click();
        }

        $(document).ready(function () {
            onLoad();
            $("#<%=ContMedication.ClientID%>").click(function () {
                if ($("#<%=ContMedication.ClientID%>").is(':checked')) {
                    $("#<%= ModifyMedicationRadButton.ClientID%>").toggle(true);
                   <%-- sVar= '<%=ContinueData%>';--%>
                    PopulateDataOnLoad(sVar);
                    fillBox();
                } else {
                    medArr = medArr.filter(function (el) { return el.id != 1; });
                    fillBox();
                    $("#<%= ModifyMedicationRadButton.ClientID%>").toggle(false);
                }

            });
            $("#<%=ContMedicationByGP.ClientID%>").click(function () {
                if ($("#<%=ContMedicationByGP.ClientID%>").is(':checked')) {
                    $("#<%= ModifyGPMedicationRadButton.ClientID%>").toggle(true); 
                   <%-- sVar1 = '<%=GPData%>';--%>
                    PopulateDataOnLoad(sVar1);
                    fillBox();
                } else {
                    medArr = medArr.filter(function (el) { return el.id != 3; });
                    fillBox();
                    $("#<%= ModifyGPMedicationRadButton.ClientID%>").toggle(false);

                }
            });
            $("#<%=ContPrescribeMedication.ClientID%>").click(function () {
                if ($("#<%=ContPrescribeMedication.ClientID%>").is(':checked')) {
                    $("#<%= ModifyPrescribeMedicationRadButton.ClientID%>").toggle(true);
                   <%-- sVar2 = '<%=HospitalData%>';--%>
                    PopulateDataOnLoad(sVar2);
                    fillBox();
                } else {
                    medArr = medArr.filter(function (el) { return el.id != 2; });
                    fillBox();
                    $("#<%= ModifyPrescribeMedicationRadButton.ClientID%>").toggle(false);

                }
            });
            $("#<%=SuggestPrescribe.ClientID%>").click(function () {
                if ($("#<%=SuggestPrescribe.ClientID%>").is(':checked')) {
                    $("#<%= ModifySuggestMedicationRadButton.ClientID%>").toggle(true);
                   <%-- sVar3 = '<%=SuggestedData%>';--%>
                    PopulateDataOnLoad(sVar3);
                    fillBox();
                } else {
                    medArr = medArr.filter(function (el) { return el.id != 4; });
                    fillBox();
                    $("#<%= ModifySuggestMedicationRadButton.ClientID%>").toggle(false);

                }
            });
            $("#<%=ModifyMedicationRadButton.ClientID%>").click(function () {
                var oWindow = radopen("PatientMedication.aspx?title=Modify Continued Medication&id=1", "ContinueMedication1", '835px', '670px');
                oWindow.set_title("Continued Medication");
                oWindow.set_visibleStatusbar(false);
                return false;
            });

            $("#<%=ModifyGPMedicationRadButton.ClientID%>").click(function () {
                var oWindow = radopen("PatientMedication.aspx?title=Set GP Prescribed Medication&id=3", "ContinueMedication2", '835px', '670px');
                oWindow.set_title("GP Prescribed Medication");
                oWindow.set_visibleStatusbar(false);
                return false;
            });

            $("#<%=ModifyPrescribeMedicationRadButton.ClientID%>").click(function () {
                var oWindow = radopen("PatientMedication.aspx?title=Set Hospital Prescribed Medication&id=2", "ContinueMedication3", '835px', '670px');
                oWindow.set_title("Hospital Prescribed Medication");
                oWindow.set_visibleStatusbar(false);
                return false;
            });

            $("#<%=ModifySuggestMedicationRadButton.ClientID%>").click(function () {
                var oWindow = radopen("PatientMedication.aspx?title=Set Suggest Medication&id=4", "ContinueMedication4", '835px', '670px');
                oWindow.set_title("Suggest Medication");
                oWindow.set_visibleStatusbar(false);
                return false;
            });
        });

        //function OnClientCloseHandler(sender, args) {
        //    var data = args.get_argument();
        //    if (data) {
        //        alert(data);
        //    }
        //}
        function fillBox() {
            if ($("#<%=ContMedication.ClientID%>").is(':checked') == false) { medArr = medArr.filter(function (el) { return el.id != 1; }); }
            if ($("#<%=ContMedicationByGP.ClientID%>").is(':checked') == false) { medArr = medArr.filter(function (el) { return el.id != 3; }); }
            if ($("#<%=ContPrescribeMedication.ClientID%>").is(':checked') == false) { medArr = medArr.filter(function (el) { return el.id != 2; }); }
            if ($("#<%=SuggestPrescribe.ClientID%>").is(':checked') == false) { medArr = medArr.filter(function (el) { return el.id != 4; }); }
            medArr.sort(function (a, b) { return parseFloat(a.id) - parseFloat(b.id); });
            if (medArr.length > 0) {
                var msg = "";
                medArr = medArr.filter(function (el) { return el.id != ""; });
                for (x in medArr) {
                    msg += medArr[x].text.trim() + ". ";
                }
                var txtdesc = $find("<%= MedicationText.ClientID%>");
                txtdesc.set_value(msg.trim());
            } else {
                var txtdesc = $find("<%= MedicationText.ClientID%>");
                 txtdesc.set_value('');
             }
         }

         function onLoad() {
             //reads variables from code behind and use it to intialise slected boxes
             sVar = '<%=ContinueData%>';
            PopulateDataOnLoad(sVar);
            sVar1 = '<%=GPData%>';
            PopulateDataOnLoad(sVar1);
            sVar2 = '<%=HospitalData%>';
            PopulateDataOnLoad(sVar2);
            sVar3 = '<%=SuggestedData%>';
            PopulateDataOnLoad(sVar3);

        }

        function PopulateDataOnLoad(data) {
            var partsOfStr = data.split('#');
            //replace medication if already exist
            var obj = medArr.filter(function (obj) {
                return obj.id === partsOfStr[0];
            })[0];

            if (obj != null) {
                obj.text = partsOfStr[1];
            } else {
                medArr.push({ id: partsOfStr[0], text: partsOfStr[1] });
            }
        }

        function CalledFn(data) {
            var partsOfStr = data.split('#');
            if (partsOfStr[0] == '1') { sVar = data; }
            if (partsOfStr[0] == '2') { sVar2 = data;  }
            if (partsOfStr[0] == '3') { sVar1 = data; }
            if (partsOfStr[0] == '4') { sVar3 = data;}
            //replace medication if already exist
            var obj = medArr.filter(function (obj) {
                return obj.id === partsOfStr[0];
            })[0];

            if (obj != null) {
                obj.text = partsOfStr[1];
            } else {
                medArr.push({ id: partsOfStr[0], text: partsOfStr[1] });
            }
            fillBox();

        }
    </script>
    <style type="text/css">
        .checkboxesTable td {
            padding-right: 10px;
            padding-bottom: 3px;
        }

        .auto-style1 {
            width: 230px;
        }
    </style>
</asp:Content>
<asp:Content ID="IDBody" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">
     <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
     <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="800px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
        <telerik:RadPane ID="ControlsRadPane" runat="server" Height="505px" Scrolling="Y">
                       <div id="ContentDiv">
                <div class="otherDataHeading">
                    <b>Patient Medication</b>
                </div>
                <div style="margin: 5px 10px;">
                    <div style="margin-top: 10px; margin-bottom: 20px;">
                        <fieldset id="DocumentationFieldset" runat="server" class="otherDataFieldset" style="width:700px;">
                            <legend>Hint</legend>
                            You can edit the text in red. But only do so after the medication has been set via the boxes and buttons. 
                            If you edit the text then try and change the medication you will be advised that the original edits will be lost.
                        </fieldset>
                    </div>

                    <div style="margin: 20px 0px 0px 0px; padding: 0px 10px 0px 0px;">
                        <fieldset id="Fieldset1" runat="server" class="otherDataFieldset" style="width:700px;">
                            <table id="table1" runat="server" cellspacing="10" cellpadding="0" border="0" style="margin: 5px; padding-bottom: 5px;">
                                <tr>
                                    <td class="auto-style1" style="width:400px;">
                                        <asp:CheckBox ID="ContMedication" runat="server" Text="Continue existing medication" AutoPostBack="false" />
                                    </td>
                                    <td class="auto-style1">
                                        <telerik:RadButton ID="ModifyMedicationRadButton" runat="server" Text="Set / Modify Medication" Skin="Windows7" style="display:none" AutoPostBack="false" Width="190"  />
                                    </td>

                                    <td></td>
                                </tr>
                                <tr>
                                    <td class="auto-style1">
                                        <asp:CheckBox ID="ContMedicationByGP" runat="server" Text="Medication to be prescribed by GP"  AutoPostBack="false"/></td>
                                    <td>
                                        <telerik:RadButton ID="ModifyGPMedicationRadButton" runat="server" Text="Set / Modify Medication" Skin="Windows7" style="display:none" AutoPostBack="false" Width="190" />
                                    </td>

                                    <td></td>
                                </tr>
                                <tr>
                                    <td class="auto-style1">
                                        <asp:CheckBox ID="ContPrescribeMedication" runat="server" Text="Medication to be prescribed by hospital" AutoPostBack="false" /></td>
                                    <td>
                                        <telerik:RadButton ID="ModifyPrescribeMedicationRadButton" runat="server" Text="Set / Modify Medication" Skin="Windows7" style="display:none" AutoPostBack="false" Width="190" />
                                    </td>

                                    <td></td>
                                </tr>
                                <tr>
                                    <td class="auto-style1">
                                        <asp:CheckBox ID="SuggestPrescribe" runat="server" Text="Suggest medication" AutoPostBack="false" /></td>
                                    <td>
                                        <telerik:RadButton ID="ModifySuggestMedicationRadButton" runat="server" Text="Set / Modify Medication" Skin="Windows7" style="display:none" AutoPostBack="false" Width="190" />
                                    </td>

                                    <td></td>
                                </tr>
                                <tr>
                                    <td colspan="4" style="height: 7px;"></td>
                                </tr>
                                <tr>
                                    <td colspan="4">&nbsp;<telerik:RadTextBox ID="MedicationText" runat="server" Skin="Office2007" TextMode="MultiLine" Height="100" Width="600" AutoPostBack="false"/></td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                </div>
            </div>
            </telerik:RadPane>

        <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
            <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
            <div style="height: 10px; margin-left: 10px; padding-top:2px; padding-bottom:2px">
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Web20" OnClientClicked="validatePage" OnClick="SaveData" Icon-PrimaryIconCssClass="telerikSaveButton" />
                <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" OnClick="CancelSave" Icon-PrimaryIconCssClass="telerikCancelButton" />
            </div>
            <div style="height:0px; display:none">
                <telerik:RadButton ID="SaveOnly" runat="server" Text="Save" Skin="Web20" OnClick="SaveOnly_Click" style="height:1px; width:1px" />
            </div>        
        </telerik:RadPane>
    </telerik:RadSplitter>
           
    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
    </telerik:RadAjaxLoadingPanel>
</asp:Content>


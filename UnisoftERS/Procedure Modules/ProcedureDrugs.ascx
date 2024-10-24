<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="ProcedureDrugs.ascx.vb" Inherits="UnisoftERS.ProcedureDrugs" %>

<style>
    .border_bottom {
        border-bottom: 1pt dashed #B8CBDE;
    }
    .error-border {
        border-color: red !important;
    }
</style>
<telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
    <script type="text/javascript">


        $(window).on('load', function () {

        });

        $(document).ready(function () {
            $(".drugs-div").find("input[type=text],input:checkbox, select, textarea").change(function () {
                ToggleNoneCheckBox($(this).attr("id"), $(this).val());
            });

            //$('.no-sedation input').on('change', function () {
            //    var drugId = -1;
            //    var dose = 0;
            //    var units = '';
            //    var checked = $(this).is(':checked');

            //    saveProcedureDrug(drugId, dose, units, checked);
            //    debugger
            //    if (checked) {
            //        $(".drugs-div").find("input:checkbox:checked").not("[name*='NoSedationChkBox']").each(function (idx, itm) {
            //            $(itm).prop("checked", false);
            //            //.not("[name*='GeneralAnaestheticChkBox']")
            //            var id = $(itm)[0].id.replace('PreMedChkBox', '');
            //            saveProcedureDrug(id, 0, 0, false);
            //        });

            //        $(".drugs-div").find("input:text").val('');

            //        if ($('#GeneralAnaestheticChkBox').is(':checked')) {
            //            $('#GeneralAnaestheticChkBox').prop("checked", false);
            //            saveProcedureDrug(-2, 0, 0, false);
            //        }
            //    }
            //});

            $('.general-anaesthetic input').on('change', function () {
                var drugId = -2;
                var dose = 0;
                var units = '';
                var checked = $(this).is(':checked');

                saveProcedureDrug(drugId, dose, units, checked);
            });

        });

        function ToggleNoneCheckBox(id, value) {
            if (id == 'NoSedationChkBox') {// || id == 'GeneralAnaestheticChkBox') {
                var drugId = -1;
                var dose = 0;
                var units = '';
                var checked = $('#NoSedationChkBox').is(':checked');

                saveProcedureDrug(drugId, dose, units, checked);
                $(".drugs-div").find("input:checkbox:checked").not("[name*='" + id + "']").not("[name*='GeneralAnaestheticChkBox']").each(function (idx, itm) {
                    $(itm).prop("checked", false);

                    var hfDrugId = $(itm)[0].id.replace('PreMedChkBox', 'hfDrugId')
                    var id = document.getElementById(hfDrugId).value

                    saveProcedureDrug(id, 0, 0, false);
                });
                //.prop("checked", false);

                $(".drugs-div").find("input:text").val('');

                if ($('#GeneralAnaestheticChkBox').is(':checked')) {
                    $('#GeneralAnaestheticChkBox').prop("checked", false);
                    saveProcedureDrug(-2, 0, 0, false);
                }

            } else {
                $('#NoSedationChkBox').prop("checked", false);
                //$('#GeneralAnaestheticChkBox').prop("checked", false);
                var drugId = -1;
                var dose = 0;
                var units = '';

                saveProcedureDrug(drugId, dose, units, false);
            }
        }

        function setDefaultValue(sender, args) {
            var elemId = sender.id;
            var hfDefDosage = elemId.replace('PreMedChkBox', 'hfDefDosage');
            var txtDosage = elemId.replace('PreMedChkBox', 'txtDosage');
            var hfDrugId = elemId.replace('PreMedChkBox', 'hfDrugId');
            var lblUnits = elemId.replace('PreMedChkBox', 'lblUnits');
            var ddlUnits = elemId.replace('PreMedChkBox', 'ddlUnits');

            if (document.getElementById(elemId).checked) {
                if (document.getElementById(txtDosage) != null) {
                    document.getElementById(txtDosage).value = document.getElementById(hfDefDosage).value;
                }
            }
            else {
                if (document.getElementById(txtDosage) != null) {
                    document.getElementById(txtDosage).value = "";
                }
            }
            setTimeout(function () {
                $('#' + txtDosage).removeClass('error-border');
            }, 1);
            if (document.getElementById(hfDrugId) != null) {
                var drugId = document.getElementById(hfDrugId).value;
                var dose = (document.getElementById(txtDosage) == null) ? 0 : document.getElementById(txtDosage).value;

                var units; //= (document.getElementById(lblResult) == null) ? 0 : document.getElementById(txtDosage).value;
                if (document.getElementById(lblUnits) != null) {
                    units = document.getElementById(lblUnits).value;
                }
                else if (document.getElementById(ddlUnits) != null) {
                    units = $find(ddlUnits).get_text();
                }
                else {
                    units = 0;
                }

                saveProcedureDrug(drugId, dose, units, document.getElementById(elemId).checked);
            }
        }

        function saveProcedureDrug(drugId, dose, units, checked) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.drugId = parseInt(drugId);
            obj.dose = (dose == '') ? 0 : parseFloat(dose);
            obj.units = '';
            obj.selected = checked;

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveProcedureDrugs",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    setRehideSummary();
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
        }

        function openPopUp() {
            var oWnd = $find("<%= ModifyDrugsListWindow.ClientID %>");
            oWnd._navigateUrl = "<%= ResolveUrl("~/Products/Options/ModifyPremedicationDrugs.aspx?option=0")%>";
            oWnd.set_title("");
            oWnd.SetSize(1000, 700);

            //Add the name of the function to be executed when RadWindow is closed.
            oWnd.add_close(OnClientClose);
            oWnd.show();
        }

        function OnClientClose(oWnd, eventArgs) {
            //Remove the OnClientClose function to avoid
            //adding it for a second time when the window is shown again.
            $("#<%=ForceReloadButton.ClientID%>").click();
            oWnd.remove_close(OnClientClose);

            <%--$find('<%=RadAjaxManager1.ClientID %>').ajaxRequest('reloaddrugs');--%>

        }

        function dosageChanged(sender, args) {
            $('#NoSedationChkBox').prop("checked", false);

            var elemId = sender.get_element().id;
            var chkDosage = elemId.replace('txtDosage', 'PreMedChkBox');
            var hfDrugId = elemId.replace('txtDosage', 'hfDrugId');
            var lblUnits = elemId.replace('txtDosage', 'lblUnits');
            var ddlUnits = elemId.replace('txtDosage', 'ddlUnits');
            var maxDoseLimit = elemId.replace('txtDosage', 'maxDoseLimit');
            var maxDoseLimitValue = parseInt(document.getElementById(maxDoseLimit).textContent);
            var drugName = elemId.replace('txtDosage', 'drugName');
            var drugNameText = document.getElementById(drugName).textContent;

            var v = sender.get_value();
            if (v > 0 && v < maxDoseLimitValue) {
                $(document.getElementById(chkDosage)).prop("checked", true);
                $(sender.get_element()).removeClass('error-border');
            } else if(v > maxDoseLimitValue) {
                $(document.getElementById(chkDosage)).prop("checked", false);
                setTimeout(function () {
                    $(sender.get_element()).addClass('error-border');
                }, 1);
                var element = document.getElementById(elemId);
                if (element) {
                }
                $find('<%=RadNotification1.ClientID%>').set_text('The maximum recommended drug dose for ' + drugNameText  + ' is ' + maxDoseLimitValue +'. Please check the dose entered');
                $find('<%=RadNotification1.ClientID%>').set_position(Telerik.Web.UI.NotificationPosition.Center);
                $find('<%=RadNotification1.ClientID%>').show();
                return;
            }

            if (document.getElementById(hfDrugId) != null) {
                var drugId = document.getElementById(hfDrugId).value;
                var dose = document.getElementById(elemId).value;

                var units;
                if (document.getElementById(lblUnits) != null) {
                    units = document.getElementById(lblUnits).value;
                }
                else if (document.getElementById(ddlUnits) != null) {
                    units = $find(ddlUnits).get_text();
                }
                else {
                    units = '';
                }

                saveProcedureDrug(drugId, dose, units, document.getElementById(chkDosage).checked);
            }
        }

        function saveDefaults() {
            <%--$find('<%=RadAjaxManager1.ClientID %>').ajaxRequest('savedefaults');--%>
        }

        function unitsChanged(sender, args) {
            var elemId = sender.get_element().id;
            var txtDosage = elemId.replace('ddlUnits', 'txtDosage');
            var chkDosage = elemId.replace('ddlUnits', 'PreMedChkBox');
            var hfDrugId = elemId.replace('ddlUnits', 'hfDrugId');
            var lblUnits = elemId.replace('ddlUnits', 'lblUnits');

            if (document.getElementById(hfDrugId) != null) {
                var drugId = document.getElementById(hfDrugId).value;
                var dose = (document.getElementById(txtDosage) == null) ? 0 : document.getElementById(txtDosage).value;
                var units = $find(elemId).get_text();

                saveProcedureDrug(drugId, dose, units, document.getElementById(chkDosage).checked);
            }

        }


    </script>
</telerik:RadScriptBlock>
<asp:ObjectDataSource ID="InsertionTechniqueSqlDataSource" runat="server" SelectMethod="GetInsertionTechniques" TypeName="UnisoftERS.OtherData" />
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<telerik:RadButton runat="server" ID="ForceReloadButton" OnClick="ForceReloadButton_Click" Style="visibility: hidden;" />

<div class="control-sub-header">Sedation/anaesthetic</div>
<div id="DrugsPage" class="drugs-div" runat="server" >
    <table style ="width : 100%" >  <%--  width added by Ferdowsi--%>
        <tr>
            <td valign="top" style=" width : 50%">
                <table id="tableNoSedation" runat="server" cellspacing="10" cellpadding="0" border="0" />
            </td>
            <td valign="top" style="padding-left: 20px ; width : 50%">
                <table id="tableAnaesthetic" runat="server" cellspacing="10" cellpadding="0" border="0" />
            </td>
        </tr>
        <%--  <tr>
            <td class="border_bottom"></td>
            <td class="border_bottom"></td>
        </tr>--%>
        <tr>
            <td valign="top" style=" width : 50%">
                <table id="tablePreMed1" runat="server" cellspacing="10" cellpadding="0" border="0" />
            </td>
            <td valign="top" style="padding-left: 20px ; width : 50%">  <%--  style added by Ferdowsi--%>
                <table id="tablePreMed2" runat="server" cellspacing="10" cellpadding="0" border="0" />
            </td>
        </tr>
        <%--  <tr>
            <td class="border_bottom"></td>
            <td class="border_bottom"></td>
        </tr>--%>
        <tr>
            <td valign="top" style="padding-top: 10px">
                <%--<telerik:RadButton ID="cmdModifyDrugs" runat="server" Text="Modify the list of drugs" OnClientClicked="openPopUp" Skin="Metro" Icon-PrimaryIconCssClass="rbEdit" AutoPostBack="false" />--%>
            </td>
            <td valign="top" style="padding-top: 10px; padding-left: 47px">
            </td>
        </tr>
    </table>
</div>
<telerik:RadWindowManager ID="PreMedWindowManager" runat="server"
    Style="z-index: 7001" Behaviors="Close, Move" AutoSize="false" Skin="Metro" EnableShadow="true" Modal="true">
    <Windows>
        <telerik:RadWindow ID="ModifyDrugsListWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true"
            Width="700px" Height="300px" Title="" VisibleStatusbar="false" InitialBehaviors="Maximize" />
    </Windows>

</telerik:RadWindowManager>

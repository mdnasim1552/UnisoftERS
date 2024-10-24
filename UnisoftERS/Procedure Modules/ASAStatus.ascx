<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="ASAStatus.ascx.vb" Inherits="UnisoftERS.ASAStatus" %>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {
        });

        $(document).ready(function () {
            $('.asa-status input').on('change', function () {
                //auto save
                var statusId = $(this).val();

                var obj = {};
                obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
                obj.patientId = parseInt(getCookie('patientId'));
                obj.asaStatusId = parseInt(statusId);

                $.ajax({
                    type: "POST",
                    url: "PreProcedure.aspx/savePatientASAStatus",
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
            });
        });


    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-section-header abnorHeader" style="margin-top: 28px">ASA Status&nbsp;<img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" /></div>
<div class="control-content">

    <asp:RadioButtonList ID="AsaStatusRadioButtonList" runat="server" CssClass="asa-status"
        CellSpacing="1" CellPadding="1" RepeatDirection="Vertical" RepeatLayout="Table" DataTextField="Description" DataValueField="UniqueId" />
</div>


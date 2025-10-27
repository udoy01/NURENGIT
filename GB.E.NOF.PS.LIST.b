SUBROUTINE GB.E.NOF.PS.LIST(Y.RETURN)
*=================================================================================================================================
* Developed by       : Nuren Durdana Abha (FDS)
* Description        : Shows data of PS from CHEQUE.REGISTER.SUPPLEMENT application
* RTN Attached in    : APPLICATION: ENQUIRY, ID: GB.ENQ.PS.ISSUE.LIST
* Routine Type       : Enquiry
* Standard Selection : NOFILE.PS.LIST
* Compilation Time   : 11 Aug, 2024 (11:41)
*=================================================================================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING CQ.ChqSubmit
    $USING FT.Contract
    $USING TT.Contract
    $USING EB.Reports
            
    GOSUB INIT
    GOSUB OPENFILE
    GOSUB SEL
RETURN
    
INIT:
    FN.CHQ= 'F.CHEQUE.REGISTER.SUPPLEMENT'
    F.CHQ= ''
    
    FN.FT= 'F.FUNDS.TRANSFER$NAU'
    F.FT= ''
    
    FN.TT= 'F.TELLER$NAU'
    F.TT= ''
RETURN
    
OPENFILE:
    EB.DataAccess.Opf(FN.CHQ,F.CHQ)
    EB.DataAccess.Opf(FN.FT,F.FT)
    EB.DataAccess.Opf(FN.TT,F.TT)
RETURN

SEL:
    LOCATE 'FROM.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING TO.POS THEN
        Y.FROM.DATE=  EB.Reports.getEnqSelection()<4,TO.POS>
    END
    
    LOCATE 'TO.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING TO.POS THEN
        Y.TO.DATE=  EB.Reports.getEnqSelection()<4,TO.POS>
    END
    
    GOSUB MAIN
RETURN

MAIN:
    SEL.CMD= 'SELECT ':FN.CHQ:' STATUS EQ ISSUED AND ID.COMP1 EQ PS AND CO.CODE EQ ': EB.SystemTables.getIdCompany()
    
    EB.DataAccess.Readlist(SEL.CMD, SELECT.LIST, '', NO.OF.ITEM, RET.CODE)
    LOOP
        REMOVE TRN.ID FROM SELECT.LIST SETTING TXN.POS
    WHILE TRN.ID:TXN.POS
    
        Y.CHQ.ID= TRN.ID
        EB.DataAccess.FRead(FN.CHQ,Y.CHQ.ID,CHQ.REC,F.CHQ,Y.ERR)
        Y.ORIGIN= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsOrigin>
        Y.ORIGIN.REF= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsOriginRef>

        Y.FT.RECORD.STATUS= ''
        IF Y.ORIGIN EQ 'FUNDS.TRANSFER' THEN
            EB.DataAccess.FRead(FN.FT,Y.ORIGIN.REF,FT.REC,F.FT,FT.ERR)
            Y.FT.RECORD.STATUS= FT.REC<FT.Contract.FundsTransfer.RecordStatus>
            
            IF Y.FT.RECORD.STATUS NE 'INAU' THEN
                GOSUB DATA.FETCH
            END
        END
        ELSE IF Y.ORIGIN EQ 'TELLER' THEN
            Y.TT.RECORD.STATUS= ''
            EB.DataAccess.FRead(FN.TT,Y.ORIGIN.REF,TT.REC,F.TT,TT.ERR)
            Y.TT.RECORD.STATUS= TT.REC<TT.Contract.Teller.TeRecordStatus>
            
            IF Y.TT.RECORD.STATUS NE 'INAU' THEN
                GOSUB DATA.FETCH
            END
        END
    
    REPEAT
RETURN

DATA.FETCH:
    EB.DataAccess.FRead(FN.CHQ,Y.CHQ.ID,CHQ.REC,F.CHQ,Y.ERR)
    Y.PS.NO= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsIdCompThr>
    Y.PAY.TO= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsPayeeName>
    Y.ISS.AMT= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsAmount>
    Y.ISS.DT= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsIssueDate>
    
    IF Y.FROM.DATE NE '' AND Y.TO.DATE NE '' THEN
        IF Y.ISS.DT GE Y.FROM.DATE AND Y.ISS.DT LE Y.TO.DATE THEN
            Y.RETURN<-1>= Y.PS.NO:'*':Y.PAY.TO:'*':Y.ISS.AMT:'*':Y.ISS.DT:'*':Y.ORIGIN.REF
            !---------------*1*---------*2*-----------*3*----------*4*-----------*5*
        END
    END
    ELSE
        Y.RETURN<-1>= Y.PS.NO:'*':Y.PAY.TO:'*':Y.ISS.AMT:'*':Y.ISS.DT:'*':Y.ORIGIN.REF
        !---------------*1*---------*2*-----------*3*----------*4*-----------*5*
    END
    
RETURN

END

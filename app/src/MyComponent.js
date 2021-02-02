import React from "react";
import { newContextComponents } from "@drizzle/react-components";
import logo from "./logo.png";

import { ToastContainer } from 'react-toastify'
import 'react-toastify/dist/ReactToastify.css'

const { AccountData, ContractData, ContractForm } = newContextComponents;

export default ({ drizzle, drizzleState }) => {
  // destructure drizzle and drizzleState from props
  return (
    <div className="App">
      <ToastContainer autoClose={false} closeOnClick={false} draggable={false} style={{ width: "1300px" }}/>
      <div>
        <img src={logo} alt="drizzle-logo" />
        <p>
          Buy crypto assets using Intallments.
        </p>
      </div>

      <div className="section">
        <h2>Active Account</h2>
        <AccountData
          drizzle={drizzle}
          drizzleState={drizzleState}
          accountIndex={0}
          units="ether"
          precision={3}
        />
      </div>

      <div className="section">
        <h2>Create a Debt Position</h2>
        <ContractForm drizzle={drizzle} drizzleState={drizzleState} contract="EPDebtCrafter" method="createDebt" 
          render={({ inputs, inputTypes, state, handleInputChange, handleSubmit }) => (
            <form onSubmit={handleSubmit}
            >
              {inputs.map((input, index) => (
                <input
                  style={{ width:1000 }}
                  key={input.name}
                  type={"text"}
                  name={input.name}
                  value={state[input.name]}
                  placeholder={input.name}
                  onChange={handleInputChange}
                />
              ))}
              <button
                key="submit"
                type="button"
                //onClick={ handleSubmit }
                onClick={ async function (){
                  console.log(drizzleState);
                  if (drizzleState.drizzleStatus.initialized) {
                    console.log("Handling createDebt");
                    var amounts = state._amounts.split(",");
                    var deadlines = state._deadlines.split(",");
                    const method = drizzle.contracts.EPDebtCrafter.methods.createDebt;
                    const txHash = await method.cacheSend(
                      state._borrowedAsset, state._borrowedAmount, state._borrowedAssetType, 
                      state._paymentAsset, state._paymentAssetType, amounts, deadlines, {
                        from: drizzleState.accounts[0]});
                      console.log("txHash = " + txHash);
                  }
                }}
                style={{  }}
              >
                Submit
              </button>
            </form>

          )}  
        />
      </div>

    </div>
  );
};

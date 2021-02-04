import React from "react";
import { DrizzleProvider, DrizzleContext } from "@drizzle/react-plugin";
import { Drizzle, generateStore, EventActions } from "@drizzle/store";
import drizzleOptions from "./drizzleOptions";
import MyComponent from "./MyComponent";
import { toast } from 'react-toastify'
import "./App.css";

const contractEventNotifier = store => next => action => {
  if (action.type === EventActions.EVENT_FIRED) {
    const contract = action.name
    const contractEvent = action.event.event
    const message = action.event.returnValues[3];//action.event.returnValues._message
    //const display = `${contract}(${contractEvent}): ${message}`
    const display = `Debt ID: ${message}`

    console.log(action);
    console.log(action.event.raw.data);

    toast.success(display, { position: toast.POSITION.TOP_LEFT })
  }
  return next(action)
}

const appMiddlewares = [ contractEventNotifier ]

const drizzleStore = generateStore({drizzleOptions,
  appMiddlewares,
  disableReduxDevTools: false  // enable ReduxDevTools!
});
const drizzle = new Drizzle(drizzleOptions, drizzleStore);
console.log(drizzle);

const App = () => {
  return (
    <DrizzleContext.Provider drizzle={drizzle}>
      <DrizzleContext.Consumer>
        {drizzleContext => {
          const { drizzle, drizzleState, initialized } = drizzleContext;

          if (!initialized) {
            return "Loading..."
          }

          return (
            <MyComponent drizzle={drizzle} drizzleState={drizzleState} />
          )
        }}
      </DrizzleContext.Consumer>
    </DrizzleContext.Provider>
  );
}

export default App;

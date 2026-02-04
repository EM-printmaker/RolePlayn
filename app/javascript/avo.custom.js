// eslint-disable-next-line no-console
console.log("Hi from Avo custom JS 👋");
import ConditionalFieldsController from "controllers/conditional_fields_controller";
const registerToGlobalStimulus = () => {
  const stimulusApp = window.Stimulus;

  if (stimulusApp) {
    if (!stimulusApp.router.modulesByIdentifier.has("conditional-fields")) {
      stimulusApp.register("conditional-fields", ConditionalFieldsController);
    }
  } else {
    setTimeout(registerToGlobalStimulus, 100);
  }
};

// 実行開始
registerToGlobalStimulus();

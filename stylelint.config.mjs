/** @type {import("stylelint").Config} */
export default {
  extends: [
    "stylelint-config-standard-scss",
    "stylelint-config-recess-order",
    "stylelint-config-prettier-scss",
  ],
  rules: {
    "property-no-vendor-prefix": null,
    "value-no-vendor-prefix": null,
  },
};

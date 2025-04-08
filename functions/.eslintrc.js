module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2020,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "object-curly-spacing": ["error", "always"],  // Add this line
    "indent": ["error", 2],  // Add this line
    "max-len": ["error", { "code": 120 }],  // Add this line
    "comma-dangle": "off",  // Add this to avoid trailing comma issues
    "no-unused-vars": ["warn"]  // Downgrade unused vars from error to warning
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};

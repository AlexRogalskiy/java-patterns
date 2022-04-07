module.exports = {
  validLabels: ['bug', 'skip-changelog', 'enhancement', 'feature'],
  mandatorySections: [
    {
      beginsWith: 'Changelog',
      endsWith: 'End of changelog',
      message: 'Changelog section is mandatory',
      validate: _ => {
        return true;
      },
    },
  ],
};

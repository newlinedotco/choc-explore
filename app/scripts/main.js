require.config({
    paths: {
        jquery: 'libs/jquery',
    },
});

require(['app'], function (app, $) {
    'use strict';
    // use app here
    console.log(app);
});

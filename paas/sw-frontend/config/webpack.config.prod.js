'use strict';

const autoprefixer = require('autoprefixer');
const path = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const ManifestPlugin = require('webpack-manifest-plugin');
const InterpolateHtmlPlugin = require('react-dev-utils/InterpolateHtmlPlugin');
const SWPrecacheWebpackPlugin = require('sw-precache-webpack-plugin');
const eslintFormatter = require('react-dev-utils/eslintFormatter');
const ModuleScopePlugin = require('react-dev-utils/ModuleScopePlugin');
const SimpleProgressWebpackPlugin = require('simple-progress-webpack-plugin')
const paths = require('./paths');
const getClientEnvironment = require('./env');
const cdnPath = require('./cdnPath');
const GlobalTheme = require('./globalTheme');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const threadLoader = require('thread-loader');
const publicPath = cdnPath();
const shouldUseSourceMap = false;
const publicUrl = publicPath.slice(0, -1);
const env = getClientEnvironment(publicUrl);
const TerserPlugin = require('terser-webpack-plugin');
// const SpeedMeasurePlugin = require("speed-measure-webpack-plugin");
// const smp = new SpeedMeasurePlugin();
threadLoader.warmup(
    [
        // 加载模块
        'babel-loader',
        'babel-preset-es2015',
    ]
);
// Note: defined here because it will be used more than once.
const OptimizeCssAssetsPlugin = require('optimize-css-assets-webpack-plugin');

module.exports = {
    // Don't attempt to continue if there are any errors.
    mode: 'production',
    bail: true,
    // We generate sourcemaps in production. This is slow but gives good results.
    // You can exclude the *.map files from the build during deployment.
    devtool: shouldUseSourceMap ? 'source-map' : false,
    // In production, we only want to load the polyfills and the app code.
    entry: {
        index: [require.resolve('./polyfills'), paths.appIndexJs],
        vendor: ['lodash', 'react-jsx-parser', 'react-router', "react-router-dom",'bizcharts'],
    },
    output: {
        // The build folder.
        path: paths.appBuild,
        filename: 'static/js/[name].[chunkhash:8].js',
        chunkFilename: 'static/js/[name].[chunkhash:8].chunk.js',
        publicPath: publicPath,
        devtoolModuleFilenameTemplate: info =>
            path
                .relative(paths.appSrc, info.absoluteResourcePath)
                .replace(/\\/g, '/'),
    },
    externals: {
        'react': 'React',
        'react-dom': 'ReactDOM',
        'moment': 'moment',
        "moment-duration-format": "moment-duration-format",
        "antd": "antd",
        "systemjs": 'System'
    },
    optimization: {
        splitChunks: {
            chunks: "all"
        },
        minimize: true,
        namedModules: true,
        usedExports: true,
        sideEffects: true,
        minimizer: [
            // This is only used in production mode
            new TerserPlugin({
                terserOptions: {
                    compress: {
                        drop_console: true,
                        ecma: 5,
                        warnings: false,
                        // Disabled because of an issue with Uglify breaking seemingly valid code:
                        // https://github.com/facebook/create-react-app/issues/2376
                        // Pending further investigation:
                        // https://github.com/mishoo/UglifyJS2/issues/2011
                        comparisons: false,
                        // Disabled because of an issue with Terser breaking valid code:
                        // https://github.com/facebook/create-react-app/issues/5250
                        // Pending further investigation:
                        // https://github.com/terser-js/terser/issues/120
                        inline: 2,
                    },
                    parallel: true,
                },
            }),
            new OptimizeCssAssetsPlugin({
                assetNameRegExp: /\.optimize\.css$/g,
                cssProcessor: require('cssnano'),
                cssProcessorOptions: { safe: true, discardComments: { removeAll: true } },
                canPrint: true
            }),
        ],

    },
    resolve: {
        modules: ['node_modules', paths.appNodeModules].concat(
            process.env.NODE_PATH.split(path.delimiter).filter(Boolean)
        ),
        extensions: ['.web.js', '.js', '.json', '.web.jsx', '.jsx', '.mjs'],
        alias: paths.namespace,
        plugins: [
            new ModuleScopePlugin(paths.appSrc, [paths.appPackageJson])
        ],
    },
    resolveLoader: {
        alias: {
            'copy': 'file-loader?name=[path][name].[ext]&context=./src'
        }
    },
    module: {
        strictExportPresence: true,
        rules: [
            {
                test: /\.(js|jsx|mjs)$/,
                enforce: 'pre',
                use: [
                    {
                        options: {
                            formatter: eslintFormatter,
                            eslintPath: require.resolve('eslint'),
                        },
                        loader: require.resolve('eslint-loader'),
                    },
                ],
                include: paths.appSrc,
            },
            {
                oneOf: [
                    // "url" loader works just like "file" loader but it also embeds
                    // assets smaller than specified size as data URLs to avoid requests.
                    {
                        test: [/\.bmp$/, /\.gif$/, /\.jpe?g$/, /\.png$/i, /\.svg$/],
                        loader: require.resolve('url-loader'),
                        options: {
                            limit: 10 * 1024,
                            name: 'static/media/[name].[hash:8].[ext]',
                        },
                    },
                    {
                        test: /\.(js|jsx|mjs)$/,
                        include: paths.appSrc,
                        use: [
                            'thread-loader',
                            {
                                loader: 'babel-loader',
                                options: {
                                    // plugins: [
                                    //     // ["transform-runtime"],
                                    //     ['import', [{ libraryName: 'antd', style: css }]],  // import less
                                    // ],
                                    compact: true,
                                    cacheDirectory: true
                                },
                            }
                        ],
                    },
                    {
                        test: /\.(css|less)$/,
                        use: [
                            {
                                loader: MiniCssExtractPlugin.loader,
                                //css位于“static/css”中，使用“../../”定位索引.html文件夹
                                //生产中`路径.publicUrlOrPath`可以是相对路径
                                options: paths.publicUrl.startsWith('.') ? { publicPath: '../../' } : {}
                            },
                            'thread-loader',
                            {
                                loader: require.resolve('css-loader'),
                                options: {
                                    importLoaders: 1,
                                },
                            },
                            {
                                loader: require.resolve('less-loader'), // compiles Less to CSS
                                options: {
                                    sourceMap: true,
                                    javascriptEnabled: true
                                }
                            },
                        ],
                    },
                    {
                        test: /\.(css|scss)$/,
                        use: [
                            {
                                loader: MiniCssExtractPlugin.loader,
                                //css位于“static/css”中，使用“../../”定位索引.html文件夹
                                //生产中`路径.publicUrlOrPath`可以是相对路径
                                options: paths.publicUrl.startsWith('.') ? { publicPath: '../../' } : {}
                            },
                            'thread-loader',
                            {
                                loader: require.resolve('css-loader'),
                                options: {
                                    importLoaders: 1,
                                },
                            },
                            {
                                loader: require.resolve('sass-loader') // compiles Less to CSS
                            },
                        ],
                    },
                    {
                        loader: require.resolve('file-loader'),
                        exclude: [/\.js$/, /\.html$/, /\.json$/, /\.mjs$/],
                        options: {
                            name: 'static/media/[name].[hash:8].[ext]',
                        },
                    },
                ],
            },
        ],
    },
    plugins: [
        new MiniCssExtractPlugin({ filename: 'static/css/[name].[hash:8].css', chunkFilename: 'static/css/[name].[hash:8].css' }),
        new SimpleProgressWebpackPlugin(),
        new HtmlWebpackPlugin({
            inject: true,
            template: paths.appHtml,
            minify: {
                removeComments: true,
                collapseWhitespace: true,
                removeRedundantAttributes: true,
                useShortDoctype: true,
                removeEmptyAttributes: true,
                removeStyleLinkTypeAttributes: true,
                keepClosingSlash: true,
                minifyJS: true,
                minifyCSS: true,
                minifyURLs: true,
            }
        }),
        new InterpolateHtmlPlugin(HtmlWebpackPlugin, env.raw),
        // Generates an `index.html` file with the <script> injected.
        new CopyWebpackPlugin([{
            from: paths.appSrc + '/publicMedia',
            to: paths.appBuild + '/static/publicMedia'
        },
        // ...runtimePaths.dependency_arr
        ]),
        new webpack.DefinePlugin(env.stringified),
        new ManifestPlugin({
            fileName: 'asset-manifest.json',
        }),
        new SWPrecacheWebpackPlugin({
            dontCacheBustUrlsMatching: /\.\w{8}\./,
            filename: 'service-worker.js',
            logger(message) {
                if (message.indexOf('Total precache size is') === 0) {
                    // This message occurs for every build and is a bit too noisy.
                    return;
                }
                if (message.indexOf('Skipping static resource') === 0) {
                    // This message obscures real errors so we ignore it.
                    // https://github.com/facebookincubator/create-react-app/issues/2612
                    return;
                }
                console.log(message);
            },
            minify: true,
            // For unknown URLs, fallback to the index page
            navigateFallback: publicUrl + '/index.html',
            // Ignores URLs starting from /__ (useful for Firebase):
            // https://github.com/facebookincubator/create-react-app/issues/2237#issuecomment-302693219
            navigateFallbackWhitelist: [/^(?!\/__).*/],
            // Don't precache sourcemaps (they're large) and build asset manifest:
            staticFileGlobsIgnorePatterns: [/\.map$/, /asset-manifest\.json$/],
        }),
        new webpack.IgnorePlugin(/^\.\/locale$/, /moment$/),
        new webpack.DefinePlugin({
            THEMES: JSON.stringify(GlobalTheme)
        })
    ],
    // Some libraries import Node modules but don't use them in the browser.
    // Tell Webpack to provide empty mocks for them so importing them works.
    node: {
        dgram: 'empty',
        fs: 'empty',
        net: 'empty',
        tls: 'empty',
        child_process: 'empty',
        __dirname: true
    },
};

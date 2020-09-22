<?php
$c=isset($_GET['c']) ? $_GET['c'] : null;
if ($c == 'info') {
    phpinfo();
    exit;
}

$db = new PDO('mysql:host=localhost', 'root', null);

function getOSInformation()
 {
     if (false == function_exists("shell_exec") || false == is_readable("/etc/os-release")) {
         return null;
     }

      $os         = shell_exec('cat /etc/os-release');
     $listIds    = preg_match_all('/.*=/', $os, $matchListIds);
     $listIds    = $matchListIds[0];

      $listVal    = preg_match_all('/=.*/', $os, $matchListVal);
     $listVal    = $matchListVal[0];

      array_walk($listIds, function(&$v, $k){
         $v = strtolower(str_replace('=', '', $v));
     });

      array_walk($listVal, function(&$v, $k){
         $v = preg_replace('/=|"/', '', $v);
     });

      return array_combine($listIds, $listVal);
 }
$osInfo = getOSInformation();
?>
<!doctype html>
<html lang=en>
<head>
    <meta charset=utf-8>
    <title>WebCore-Docker</title>

    <style>
        @import 'https://fonts.googleapis.com/css?family=Montserrat|Raleway|Source+Code+Pro';

        body { font-family: 'Raleway', sans-serif; }
        h2 { font-family: 'Montserrat', sans-serif; }
        pre {
            font-family: 'Source Code Pro', monospace;

            padding: 16px;
            overflow: auto;
            font-size: 85%;
            line-height: 1.02;
            background-color: #f7f7f7;
            border-radius: 3px;

            word-wrap: normal;
        }

        .container {
            max-width: 1024px;
            width: 100%;
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <!--img src="https://cdn.rawgit.com/kubuslab/docker-webcore/831976c022782e592b7e2758464b2a9efe3da042/docs/logo.svg" alt="Docker LAMP logo" /-->
            <h2>Welcome to <a href="https://hub.docker.com/r/kubuslab/webcore" target="_blank">WebCore-Docker</a> kubuslab/webcore</h2>
        </header>
        <article>
            <p>
                For documentation, <a href="https://hub.docker.com/r/kubuslab/webcore" target="_blank">click here</a>.
            </p>
        </article>
        <section>
            <pre>
OS: <?php echo $osInfo['pretty_name']; ?><br/>
Apache: <?php echo apache_get_version(); ?><br/>
MySQL Version: <?php echo $db->getAttribute( PDO::ATTR_SERVER_VERSION ); ?><br/>
PHP Version: <?php echo phpversion(); ?> <a href="/?c=info" target="_blank">View Info</a><br/>
phpMyAdmin Version: <?php echo getenv('PHPMYADMIN_VERSION'); ?> <a href="/phpmyadmin" target="_blank">Go to PhpMyAdmin</a><br/>
WebCore Version: <?php echo class_exists('\WebCore\AppContext') ? \WebCore\AppContext::VERSION : '<i><unknown></i>'; ?>
            </pre>
        </section>

        <article>
            <p>
                Project on this container:
            </p>
        </article>
        <?php
        $files = array_flip(scandir('/app/'));
        unset($files['.'], $files['..'], $files['lib'], $files['index.php']);
        $dirs = [];
        foreach ($files as $key => $value) {
            if (is_dir('/app/' . $key) && is_dir('/app/' . $key . '/application/controllers')) {
                $dirs[] = $key;
            }
        }
        ?>
        <section>
            <?php if (count($dirs) > 0):
            foreach ($dirs as $d) :?>
            <ul>
                <li><a href="/<?= $d ?>/" target="_blank"><?= $d ?></a></li>
            </ul>
            <?php 
            endforeach;
            else:?>
                <pre><i>NO PROJECT FOUND</i></pre>
            <?php endif;?>
        </section>
    </div>
</body>
</html>

<?php

declare(strict_types=1);
/**
 * This file is part of MoChat.
 * @link     https://mo.chat
 * @document https://mochat.wiki
 * @contact  group@mo.chat
 * @license  https://github.com/mochat-cloud/mochat/blob/master/LICENSE
 */
namespace MoChat\Plugin\ContactMessageBatchSend\Action\Dashboard;

use EasyWeChat\Kernel\Exceptions\InvalidConfigException;
use GuzzleHttp\Exception\GuzzleException;
use Hyperf\Di\Annotation\Inject;
use Hyperf\HttpServer\Annotation\Controller;
use Hyperf\HttpServer\Annotation\RequestMapping;
use Hyperf\HttpServer\Annotation\Middlewares;
use Hyperf\HttpServer\Annotation\Middleware;
use MoChat\App\Common\Middleware\DashboardAuthMiddleware;
use MoChat\App\Rbac\Middleware\PermissionMiddleware;
use MoChat\App\Corp\Logic\AppTrait;
use MoChat\App\Utils\File;
use MoChat\Framework\Action\AbstractAction;
use MoChat\Framework\Constants\ErrorCode;
use MoChat\Framework\Exception\CommonException;
use MoChat\Framework\Request\ValidateSceneTrait;
use MoChat\Plugin\ContactMessageBatchSend\Logic\StoreLogic;

/**
 * 客户消息群发 - 新建消息.
 * @Controller
 */
class Store extends AbstractAction
{
    use ValidateSceneTrait;
    use AppTrait;

    /**
     * @Inject
     * @var StoreLogic
     */
    private $storeLogic;

    /**
     * @Middlewares({
     *     @Middleware(DashboardAuthMiddleware::class),
     *     @Middleware(PermissionMiddleware::class)
     * })
     * @RequestMapping(path="/dashboard/contactMessageBatchSend/store", methods="POST")
     */
    public function handle(): array
    {
        ## 参数验证
        $params = $this->request->all();
        $this->validated($params);
        $content = (array) json_decode($params['content'], true);
        ## 验证消息参数
        $content = $this->validContent($content);
        ## 接收参数
        $params = [
            'employeeIds'  => $params['employeeIds'],
            'filterParams' => json_decode($params['filterParams'], true),
            'content'      => $content,
            'sendWay'      => $params['sendWay'],
            'definiteTime' => $params['definiteTime'] ?? null,
        ];
        $this->storeLogic->handle($params, user());
        return [];
    }

    /**
     * 验证规则.
     *
     * @return array 响应数据
     */
    protected function rules(): array
    {
        return [
            'employeeIds'  => 'required',
            'filterParams' => 'json',
            'content'      => 'required|json',
            'sendWay'      => 'required|in:1,2',
            'definiteTime' => 'required_with:sendWay|date',
        ];
    }

    /**
     * 验证错误提示.
     * @return array 响应数据
     */
    protected function messages(): array
    {
        return [];
    }

    /**
     * 验证消息内容参数.
     */
    protected function validContent(array $content): array
    {
        if (count($content) == 0) {
            throw new CommonException(ErrorCode::INVALID_PARAMS, '消息内容不能为空');
        }
        foreach ($content as $k=>$item) {
            if (empty($item['msgType'])) {
                continue;
            }
            switch ($item['msgType']) {
                case 'text':
                    if (empty($item['text']['content'])) {
                        throw new CommonException(ErrorCode::INVALID_PARAMS, '消息类型不能为空');
                    }
                    if (strlen($item['text']['content']) > 4000) {
                        throw new CommonException(ErrorCode::INVALID_PARAMS, '消息文本内容长度超过限制');
                    }
                    break;
                case 'image':
                    if (empty($item['image']['media_id']) && empty($item['image']['pic_url'])) {
                        throw new CommonException(ErrorCode::INVALID_PARAMS, '图片参数有误');
                    }
                    $content[$k]['image']['media_id'] = $this->handlePic($item['image']['pic_url'],2);
                    break;
                case 'link':
                    if (empty($item['link']['title'])) {
                        throw new CommonException(ErrorCode::INVALID_PARAMS, '链接标题不能为空');
                    }
                    if (empty($item['link']['url'])) {
                        throw new CommonException(ErrorCode::INVALID_PARAMS, '链接链接不能为空');
                    }
                    if (! empty($item['link']['desc']) && strlen($item['link']['desc']) > 250) {
                        throw new CommonException(ErrorCode::INVALID_PARAMS, '链接描述长度超过限制');
                    }
                    if (!empty($item['link']['pic_url'])){
                        $content[$k]['link']['picurl'] = $this->handlePic($item['link']['pic_url'],1);
                    }
                    break;
                case 'miniprogram':
                    if (empty($item['miniprogram']['title'])) {
                        throw new CommonException(ErrorCode::INVALID_PARAMS, '小程序消息标题不能为空');
                    }
                    if (strlen($item['miniprogram']['title']) > 64) {
                        throw new CommonException(ErrorCode::INVALID_PARAMS, '小程序消息标题长度超过限制');
                    }
                    if (empty($item['miniprogram']['pic_media_id'])) {
                        throw new CommonException(ErrorCode::INVALID_PARAMS, '小程序消息封面不能为空');
                    }
                    if (empty($item['miniprogram']['appid'])) {
                        throw new CommonException(ErrorCode::INVALID_PARAMS, '小程序appid不能为空');
                    }
                    if (empty($item['miniprogram']['page'])) {
                        throw new CommonException(ErrorCode::INVALID_PARAMS, '小程序page路径不能为空');
                    }
                    $content[$k]['miniprogram']['pic_url'] = $item['miniprogram']['pic_media_id'];
                    $content[$k]['miniprogram']['pic_media_id'] = $this->handlePic($item['miniprogram']['pic_media_id'],2);
                    break;
                default:
                    throw new CommonException(ErrorCode::INVALID_PARAMS, '暂不支持的消息类型');
            }
        }
        return $content;
    }

    protected function handlePic($pic,$type){
        $localFile = realpath(rtrim(config('file.storage.local.root'), '/') . '/' . $pic);
        if ($type === 1){
            ##EasyWeChat上传图片
            $uploadRes = $this->wxApp(user()['corpIds'][0], 'contact')->media->uploadImg($localFile);
            if ($uploadRes['errcode'] !== 0) {
                throw new CommonException(ErrorCode::INVALID_PARAMS, '上传图片失败');
            }
            return $uploadRes['url'];
        }
        ##EasyWeChat上传临时素材
        $uploadRes = $this->wxApp(user()['corpIds'][0], 'contact')->media->uploadFile($localFile);
        if ((int) $uploadRes['errcode'] !== 0) {
            throw new CommonException(ErrorCode::INVALID_PARAMS, '上传临时素材失败');
        }
        return $uploadRes['media_id'];
    }
}
